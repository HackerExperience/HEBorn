module Apps.TaskManager.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.CssHelpers
import UI.Widgets exposing (progressBar, lineGraph)
import UI.ToString exposing (bibytesToString, bitsPerSecondToString, frequencyToString, secondsToTimeNotation)
import Game.Models exposing (GameModel)
import Apps.TaskManager.Messages exposing (Msg(..))
import Apps.TaskManager.Models exposing (..)
import Apps.TaskManager.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "taskmngr"


viewTaskRowUsage : ResourceUsage -> List (Html Msg)
viewTaskRowUsage usage =
    [ div [] [ text (frequencyToString usage.cpu) ]
    , div [] [ text (bibytesToString usage.mem) ]
    , div [] [ text (bitsPerSecondToString usage.down) ]
    , div [] [ text (bitsPerSecondToString usage.up) ]
    ]


etaBar : Int -> Int -> Html Msg
etaBar now total =
    progressBar
        (1
            - (toFloat now)
            / (toFloat total)
        )
        (secondsToTimeNotation now)
        16


viewTaskRow : TaskEntry -> Html Msg
viewTaskRow entry =
    div [ class [ EntryDivision ] ]
        [ div []
            [ div [] [ text entry.title ]
            , div [] [ text "Target: ", text entry.target ]
            , div []
                [ text "File: "
                , text entry.appFile
                , span [] [ text (toString entry.appVer) ]
                ]
            ]
        , div [] [ etaBar entry.etaNow entry.etaTotal ]
        , div [] (viewTaskRowUsage entry.usage)
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
        [ viewTasksTable app.tasks
        , viewTotalResources app
        ]
