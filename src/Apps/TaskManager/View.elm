module Apps.TaskManager.View exposing (view)

import Dict
import Utils exposing (andThenWithDefault)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.CssHelpers
import UI.Widgets exposing (progressBar, lineGraph)
import UI.ToString exposing (bibytesToString, bitsPerSecondToString, frequencyToString, secondsToTimeNotation)
import Game.Models exposing (GameModel)
import Game.Servers.Processes.Models as Processes exposing (..)
import Apps.TaskManager.Messages exposing (Msg(..))
import Apps.TaskManager.Models exposing (..)
import Apps.TaskManager.Style exposing (Classes(..))
import Apps.TaskManager.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "taskmngr"


processName : Process -> String
processName it =
    case it.processType of
        Cracker ->
            "Cracker"

        Decryptor ->
            "Decryptor"

        Encryptor ->
            "Encryptor"

        FileDownload ->
            "FileDownload"

        LogDeleter ->
            "LogDeleter"


viewTaskRowUsage : ResourceUsage -> List (Html Msg)
viewTaskRowUsage usage =
    [ div [] [ text (frequencyToString usage.cpu) ]
    , div [] [ text (bibytesToString usage.mem) ]
    , div [] [ text (bitsPerSecondToString usage.down) ]
    , div [] [ text (bitsPerSecondToString usage.up) ]
    ]


etaBar : Float -> Float -> Html Msg
etaBar secondsLeft progress =
    progressBar
        progress
        (secondsToTimeNotation (floor secondsLeft))
        16


viewState : Process -> Html Msg
viewState entry =
    case entry.state of
        StateRunning completeTime ->
            etaBar (completeTime - 0) entry.progress

        StateStandby ->
            text "Processing..."

        StatePaused ->
            text "Paused"

        StateComplete ->
            text "Finished"


processMenu : Process -> Attribute Msg
processMenu entry =
    case entry.state of
        StateRunning completeTime ->
            menuForRunning entry.id

        StatePaused ->
            menuForPaused entry.id

        _ ->
            menuForComplete entry.id


viewTaskRow : Process -> Html Msg
viewTaskRow entry =
    let
        name =
            processName entry

        fileName =
            Maybe.withDefault "N/F" entry.fileID

        fileVer =
            andThenWithDefault toString "N/V" entry.version

        usage =
            packUsage entry
    in
        div [ class [ EntryDivision ], (processMenu entry) ]
            [ div []
                [ div [] [ text name ]
                , div [] [ text "Target: ", text entry.targetServerID ]
                , div []
                    [ text "File: "
                    , text fileName
                    , span [] [ text fileVer ]
                    ]
                ]
            , div [] [ viewState entry ]
            , div [] (viewTaskRowUsage usage)
            ]


viewTasksTable : Entries -> Html Msg
viewTasksTable entries =
    div [ class [ TaskTable ] ]
        ([ div [ class [ EntryDivision ] ]
            -- TODO: Hide when too small (responsive design)
            [ div [] [ text "Process" ]
            , div [] [ text "ETA" ]
            , div [] [ text "Resources" ]
            ]
         ]
            ++ (List.map viewTaskRow entries)
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
viewTotalResources ({ historyCPU, historyMem, historyDown, historyUp, limits } as app) =
    div [ class [ BottomGraphsRow ] ]
        [ viewGraphUsage "CPU" "green" historyCPU limits.cpu
        , viewGraphUsage "Memory" "blue" historyMem limits.mem
        , viewGraphUsage "Downlink" "red" historyDown limits.down
        , viewGraphUsage "Uplink" "yellow" historyUp limits.up
        ]


view : GameModel -> Model -> Html Msg
view game ({ app } as model) =
    div [ class [ MainLayout ] ]
        [ viewTasksTable (Dict.values app.localTasks)
        , viewTotalResources app
        , menuView model
        ]
