module Apps.TaskManager.View exposing (view)

import Dict
import Time exposing (Time)
import Html exposing (..)
import Html.CssHelpers
import UI.Widgets.ProgressBar exposing (progressBar)
import UI.Widgets.LineGraph exposing (lineGraph)
import UI.ToString exposing (bibytesToString, bitsPerSecondToString, frequencyToString, secondsToTimeNotation)
import Game.Data as Game
import Game.Models
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Models as Servers
import Game.Shared exposing (ID)
import Game.Servers.Processes.Models as Processes
import Apps.TaskManager.Messages exposing (Msg(..))
import Apps.TaskManager.Models exposing (..)
import Apps.TaskManager.Resources exposing (Classes(..), prefix)
import Apps.TaskManager.Menu.View exposing (..)


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    let
        tasks =
            data
                |> Game.getActiveServer
                |> Servers.getProcesses
                |> Processes.toList
    in
        div [ class [ MainLayout ] ]
            [ viewTasksTable data tasks data.game.meta.lastTick
            , viewTotalResources app
            , menuView model
            ]



-- PRIVATE


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix



-- private


maybe : Maybe (Html msg) -> Html msg
maybe =
    Maybe.withDefault <| text ""


viewTaskRowUsage : ResourceUsage -> Html Msg
viewTaskRowUsage usage =
    div []
        [ div [] [ text (frequencyToString usage.cpu) ]
        , div [] [ text (bibytesToString usage.mem) ]
        , div [] [ text (bitsPerSecondToString usage.down) ]
        , div [] [ text (bitsPerSecondToString usage.up) ]
        ]


etaBar : Time -> Float -> Html Msg
etaBar secondsLeft progress =
    let
        formattedTime =
            secondsToTimeNotation secondsLeft
    in
        progressBar progress formattedTime 16


viewState : Time -> Processes.Process -> Html Msg
viewState now proc =
    case Processes.getState proc of
        Processes.Starting ->
            text "Starting..."

        Processes.Running ->
            let
                progress =
                    Processes.getProgressPercentage proc

                timeLeft =
                    proc
                        |> Processes.getCompletionDate
                        |> Maybe.map (flip (-) now)
                        |> Maybe.withDefault 0
            in
                progress
                    |> Maybe.map (etaBar timeLeft)
                    |> maybe

        Processes.Paused ->
            text "Paused"

        Processes.Concluded ->
            text "Completed"

        Processes.Succeeded ->
            text "Completed (success)"

        Processes.Failed _ ->
            -- TODO: match reason
            text "Completed (failure)"


processMenu : ( Processes.ID, Processes.Process ) -> Attribute Msg
processMenu ( id, process ) =
    let
        menu =
            case Processes.getAccess process of
                Processes.Full _ ->
                    case Processes.getState process of
                        Processes.Running ->
                            menuForRunning

                        Processes.Paused ->
                            menuForPaused

                        _ ->
                            menuForComplete

                Processes.Partial _ ->
                    menuForPartial
    in
        menu id


viewTaskRow :
    Game.Data
    -> Time
    -> ( Processes.ID, Processes.Process )
    -> Html Msg
viewTaskRow data now (( _, process ) as entry) =
    let
        maybeAnd ma mb =
            Maybe.andThen (\a -> Maybe.map (\b -> ( a, b )) mb) ma

        fileInfo =
            let
                servers =
                    data
                        |> Game.getGame
                        |> Game.Models.getServers

                maybeFileID =
                    Processes.getFileID process

                maybeFilesystem =
                    process
                        |> Processes.getOrigin
                        |> Maybe.andThen (flip Servers.get servers)
                        |> Maybe.map Servers.getFilesystem

                fileInformation fileName =
                    div []
                        [ text "File:"
                        , text fileName
                        , process
                            |> Processes.getVersion
                            |> Maybe.map
                                (toString
                                    >> text
                                    >> List.singleton
                                    >> span []
                                )
                            |> maybe
                        ]
            in
                maybeAnd maybeFileID maybeFilesystem
                    |> Maybe.andThen (uncurry Filesystem.getEntry)
                    |> Maybe.map Filesystem.getEntryName
                    |> Maybe.map fileInformation
                    |> maybe

        usageView =
            process
                |> Processes.getUsage
                |> Maybe.map (packUsage >> viewTaskRowUsage)
                |> maybe
    in
        div [ class [ EntryDivision ], (processMenu entry) ]
            [ div []
                [ text <| Processes.getName process
                , br [] []
                , text "Target: "
                , text <| Tuple.second <| Processes.getTarget process
                , br [] []
                , fileInfo
                ]
            , div []
                [ viewState now process ]
            , div []
                [ usageView ]
            ]


viewTasksTable : Game.Data -> Entries -> Time -> Html Msg
viewTasksTable data entries now =
    div [ class [ TaskTable ] ]
        ([ div [ class [ EntryDivision ] ]
            -- TODO: Hide when too small (responsive design)
            [ div [] [ text "Process" ]
            , div [] [ text "ETA" ]
            , div [] [ text "Resources" ]
            ]
         ]
            ++ (List.map (viewTaskRow data now) entries)
        )


viewGraphUsage : String -> String -> List Float -> Float -> Html Msg
viewGraphUsage title color history limit =
    let
        sz =
            toFloat ((List.length history) - 1)

        points =
            (List.indexedMap
                (\i x ->
                    ( (1 - toFloat (i) / sz)
                    , (1 - x / limit)
                    )
                )
                history
            )
    in
        lineGraph points color 50 True ( 3, 1 )


viewTotalResources : TaskManager -> Html Msg
viewTotalResources model =
    let
        { historyCPU, historyMem, historyDown, historyUp, limits } =
            model
    in
        div [ class [ BottomGraphsRow ] ]
            [ viewGraphUsage "CPU" "green" historyCPU limits.cpu
            , viewGraphUsage "Memory" "blue" historyMem limits.mem
            , viewGraphUsage "Downlink" "red" historyDown limits.down
            , viewGraphUsage "Uplink" "yellow" historyUp limits.up
            ]
