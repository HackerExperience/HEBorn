module Apps.TaskManager.View exposing (view)

import ContextMenu
import Time exposing (Time)
import Html exposing (..)
import Html.CssHelpers
import UI.Widgets.ProgressBar exposing (progressBar)
import UI.Widgets.LineGraph exposing (lineGraph)
import UI.ToString exposing (bibytesToString, bitsPerSecondToString, frequencyToString, secondsToTimeNotation)
import Game.Servers.Processes.Models as Processes
import Apps.TaskManager.Config exposing (..)
import Apps.TaskManager.Models exposing (..)
import Apps.TaskManager.Resources exposing (Classes(..), prefix)


view : Config msg -> Model -> Html msg
view config model =
    div [ class [ MainLayout ] ]
        [ viewTasksTable config
        , viewTotalResources model
        ]



-- PRIVATE


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


viewTaskRowUsage : Processes.ResourcesUsage -> Html msg
viewTaskRowUsage usage =
    let
        un =
            Processes.getUnitUsage >> toFloat
    in
        div []
            [ div [] [ text (frequencyToString <| un usage.cpu) ]
            , div [] [ text (bibytesToString <| un usage.mem) ]
            , div [] [ text (bitsPerSecondToString <| un usage.down) ]
            , div [] [ text (bitsPerSecondToString <| un usage.up) ]
            ]


etaBar : Time -> Float -> Html msg
etaBar secondsLeft progress =
    let
        formattedTime =
            secondsToTimeNotation secondsLeft
    in
        progressBar progress formattedTime 16


syncProgress : Time -> Time -> Float -> Float -> Float
syncProgress now lastSync remaining lastProgress =
    if (remaining <= 0) || (lastProgress >= 1) then
        1
    else
        (now - lastSync)
            / remaining
            * (1 - lastProgress)
            + lastProgress


viewState : Time -> Time -> Processes.Process -> Html msg
viewState now lastRecalc proc =
    case Processes.getState proc of
        Processes.Starting ->
            text "Starting..."

        Processes.Running ->
            let
                lastProgress =
                    proc
                        |> Processes.getProgressPercentage

                maybeCompletitionDate =
                    Processes.getCompletionDate proc

                timeLeft =
                    Maybe.map
                        (flip (-) now >> max 0)
                        maybeCompletitionDate

                progress =
                    Maybe.map2
                        (syncProgress now lastRecalc)
                        timeLeft
                        lastProgress
            in
                progress
                    |> Maybe.map2 etaBar timeLeft
                    |> Maybe.withDefault (text "")

        Processes.Paused ->
            text "Paused"

        Processes.Concluded ->
            text "Completed"

        Processes.Succeeded ->
            text "Completed (success)"

        Processes.Failed _ ->
            -- TODO: match reason
            text "Completed (failure)"


processMenu : Config msg -> ( Processes.ID, Processes.Process ) -> Attribute msg
processMenu config ( id, process ) =
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
        menu config id


menuForRunning : Config msg -> Processes.ID -> Attribute msg
menuForRunning { menuAttr, onPause, onRemove } pID =
    menuAttr
        [ [ ( ContextMenu.item "Pause", onPause pID )
          , ( ContextMenu.item "Remove", onRemove pID )
          ]
        ]


menuForPaused : Config msg -> Processes.ID -> Attribute msg
menuForPaused { menuAttr, onResume, onRemove } pID =
    menuAttr
        [ [ ( ContextMenu.item "Resume", onResume pID )
          , ( ContextMenu.item "Remove", onRemove pID )
          ]
        ]


menuForComplete : Config msg -> Processes.ID -> Attribute msg
menuForComplete { menuAttr, onRemove } pID =
    menuAttr
        [ [ ( ContextMenu.item "Remove", onRemove pID )
          ]
        ]


menuForPartial : Config msg -> Processes.ID -> Attribute msg
menuForPartial { menuAttr } _ =
    menuAttr []


viewTaskRow :
    Config msg
    -> ( Processes.ID, Processes.Process )
    -> Html msg
viewTaskRow config (( _, process ) as entry) =
    let
        lastRecalc =
            config.processes
                |> Processes.getLastModified

        usageView =
            process
                |> Processes.getUsage
                |> Maybe.map (viewTaskRowUsage)
                |> Maybe.withDefault (text "")
    in
        div
            [ class [ EntryDivision ]
            , processMenu config entry
            ]
            [ div []
                [ text <| Processes.getName process
                , br [] []
                , text "Target: "
                , text <| Tuple.second <| Processes.getTarget process
                , br [] []
                ]
            , div []
                [ viewState config.lastTick lastRecalc process ]
            , div []
                [ usageView ]
            ]


viewTasksTable : Config msg -> Html msg
viewTasksTable config =
    let
        first =
            div [ class [ EntryDivision ] ]
                [ div [] [ text "Process" ]
                , div [] [ text "ETA" ]
                , div [] [ text "Resources" ]
                ]

        tasks =
            config.processes
                |> Processes.toList
    in
        tasks
            |> List.map (viewTaskRow config)
            |> (::) first
            |> div [ class [ TaskTable ] ]


viewGraphUsage : String -> String -> List Float -> Html msg
viewGraphUsage title color history =
    let
        sz =
            toFloat ((List.length history) - 1)

        points =
            (List.indexedMap
                (\i x ->
                    ( (1 - toFloat (i) / sz)
                    , (1 - x)
                    )
                )
                history
            )
    in
        lineGraph points color 50 True ( 3, 1 )


viewTotalResources : Model -> Html msg
viewTotalResources { historyCPU, historyMem, historyDown, historyUp } =
    div [ class [ BottomGraphsRow ] ]
        [ viewGraphUsage "CPU" "green" historyCPU
        , viewGraphUsage "Memory" "blue" historyMem
        , viewGraphUsage "Downlink" "red" historyDown
        , viewGraphUsage "Uplink" "yellow" historyUp
        ]
