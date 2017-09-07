module Apps.TaskManager.View exposing (view)

import Dict
import Time exposing (Time)
import Html exposing (..)
import Html.CssHelpers
import UI.Widgets.ProgressBar exposing (progressBar)
import UI.Widgets.LineGraph exposing (lineGraph)
import UI.ToString exposing (bibytesToString, bitsPerSecondToString, frequencyToString, secondsToTimeNotation)
import Game.Data as Game
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
            data.server
                |> Servers.getProcesses
                |> Processes.toList
    in
        div [ class [ MainLayout ] ]
            [ viewTasksTable tasks data.game.meta.lastTick
            , viewTotalResources app
            , menuView model
            ]



-- PRIVATE


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix



-- private


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
                    Processes.getProgressPct proc

                timeLeft =
                    proc
                        |> Processes.getCompletionDate
                        |> Maybe.map (flip (-) now)
                        |> Maybe.withDefault 0
            in
                etaBar timeLeft progress

        Processes.Standby ->
            text "Processing..."

        Processes.Paused ->
            text "Paused"

        Processes.Completed _ ->
            -- TODO: match completion result
            text "Finished"


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


viewTaskRow : Time -> ( Processes.ID, Processes.Process ) -> Html Msg
viewTaskRow now (( _, process ) as entry) =
    let
        name =
            Processes.getName process

        fileName =
            -- TODO: fetch actual file name
            process
                |> Processes.getFileID
                |> Maybe.withDefault "HIDDEN"

        fileVer =
            process
                |> Processes.getVersion
                |> Maybe.map toString
                |> Maybe.withDefault "N/V"

        usage =
            process
                |> Processes.getUsage
                |> Maybe.map (packUsage >> viewTaskRowUsage)

        target =
            -- TODO: fetch server ip
            Processes.getTarget process

        maybe =
            Maybe.withDefault (div [] [])
    in
        div [ class [ EntryDivision ], (processMenu entry) ]
            [ div []
                [ div [] [ text name ]
                , div [] [ text "Target: ", text target ]
                , div []
                    [ text "File: "
                    , text fileName
                    , span [] [ text fileVer ]
                    ]
                ]
            , div [] [ viewState now process ]
            , maybe usage
            ]


viewTasksTable : Entries -> Time -> Html Msg
viewTasksTable entries now =
    div [ class [ TaskTable ] ]
        ([ div [ class [ EntryDivision ] ]
            -- TODO: Hide when too small (responsive design)
            [ div [] [ text "Process" ]
            , div [] [ text "ETA" ]
            , div [] [ text "Resources" ]
            ]
         ]
            ++ (List.map (viewTaskRow now) entries)
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
