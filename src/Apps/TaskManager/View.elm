module Apps.TaskManager.View exposing (view)

import Dict
import Time exposing (Time)
import Html exposing (..)
import Html.CssHelpers
import UI.Widgets.ProgressBar exposing (progressBar)
import UI.Widgets.LineGraph exposing (lineGraph)
import UI.ToString exposing (bibytesToString, bitsPerSecondToString, frequencyToString, secondsToTimeNotation)
import Game.Data as Game
import Game.Servers.Processes.Models as Processes exposing (..)
import Game.Servers.Processes.Types.Local as Local exposing (ProcessProp, ProcessState(..))
import Game.Servers.Processes.Types.Remote as Remote exposing (ProcessProp)
import Apps.TaskManager.Messages exposing (Msg(..))
import Apps.TaskManager.Models exposing (..)
import Apps.TaskManager.Style exposing (Classes(..))
import Apps.TaskManager.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "taskmngr"


processName : Process -> String
processName entry =
    case entry.prop of
        LocalProcess it ->
            (case it.processType of
                Local.Cracker _ ->
                    "Cracker"

                Local.Decryptor _ _ _ ->
                    "Decryptor"

                Local.Encryptor _ _ ->
                    "Encryptor"

                Local.FileTransference _ ->
                    "File Transference"

                Local.LogForge _ _ _ ->
                    "Log Forge"

                Local.PassiveFirewall _ ->
                    "Passive Firewall"
            )

        RemoteProcess it ->
            (case it.processType of
                Remote.Cracker ->
                    "Cracker"

                Remote.Decryptor _ _ ->
                    "Decryptor"

                Remote.Encryptor _ ->
                    "Encryptor"

                Remote.FileTransference _ ->
                    "File Transference"

                Remote.LogForge _ ->
                    "Log Forge"
            )


viewTaskRowUsage : ResourceUsage -> List (Html Msg)
viewTaskRowUsage usage =
    [ div [] [ text (frequencyToString usage.cpu) ]
    , div [] [ text (bibytesToString usage.mem) ]
    , div [] [ text (bitsPerSecondToString usage.down) ]
    , div [] [ text (bitsPerSecondToString usage.up) ]
    ]


etaBar : Time -> Float -> Html Msg
etaBar secondsLeft progress =
    progressBar
        progress
        (secondsToTimeNotation secondsLeft)
        16


viewState : Time -> Process -> Html Msg
viewState now entry =
    case entry.prop of
        LocalProcess prop ->
            (case prop.state of
                StateRunning ->
                    etaBar
                        (prop.eta |> Maybe.map ((flip (-)) now) |> Maybe.withDefault 0)
                        (Maybe.withDefault 0 prop.progress)

                StateStandby ->
                    text "Processing..."

                StatePaused ->
                    text "Paused"

                StateComplete ->
                    text "Finished"
            )

        RemoteProcess _ ->
            text "Running"


processMenu : Process -> Attribute Msg
processMenu process =
    (case process.prop of
        LocalProcess entry ->
            (case entry.state of
                StateRunning ->
                    menuForRunning

                StatePaused ->
                    menuForPaused

                _ ->
                    menuForComplete
            )

        RemoteProcess entry ->
            menuForRemote
    )
        process.id


fromLocal : (Local.ProcessProp -> a) -> a -> Process -> a
fromLocal toGet default process =
    case process.prop of
        LocalProcess data ->
            toGet data

        _ ->
            default


getVersion : Local.ProcessProp -> Maybe Float
getVersion prop =
    case prop.processType of
        Local.Cracker v ->
            Just v

        Local.Decryptor v _ _ ->
            Just v

        Local.Encryptor v _ ->
            Just v

        Local.FileTransference _ ->
            Nothing

        Local.LogForge v _ _ ->
            Just v

        Local.PassiveFirewall v ->
            Just v


viewTaskRow : Time -> Process -> Html Msg
viewTaskRow now entry =
    let
        name =
            processName entry

        fileName =
            fromLocal
                (\d -> Maybe.withDefault "UNKNOWN" d.fileID)
                "HIDDEN"
                entry

        fileVer =
            entry
                |> fromLocal getVersion Nothing
                |> Maybe.andThen (toString >> Just)
                |> Maybe.withDefault "N/V"

        usage =
            fromLocal
                (\d -> packUsage d)
                (ResourceUsage -1 -1 -1 -1)
                entry

        target =
            fromLocal
                (\d -> d.targetServerID)
                "localhost"
                entry
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
            , div [] [ viewState now entry ]
            , div [] (viewTaskRowUsage usage)
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
viewTotalResources ({ historyCPU, historyMem, historyDown, historyUp, limits } as app) =
    div [ class [ BottomGraphsRow ] ]
        [ viewGraphUsage "CPU" "green" historyCPU limits.cpu
        , viewGraphUsage "Memory" "blue" historyMem limits.mem
        , viewGraphUsage "Downlink" "red" historyDown limits.down
        , viewGraphUsage "Uplink" "yellow" historyUp limits.up
        ]


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    let
        tasks =
            data.server.processes
    in
        div [ class [ MainLayout ] ]
            [ viewTasksTable (Dict.values tasks) data.game.meta.lastTick
            , viewTotalResources app
            , menuView model
            ]
