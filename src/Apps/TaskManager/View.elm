module Apps.TaskManager.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.CssHelpers
import Utils exposing (floatToPrefixedValues, secondsToTimeNotation)
import Svg exposing (svg, polyline, polygon)
import Svg.Attributes as SvgA exposing (width, height, viewBox, fill, stroke, strokeWidth, points, preserveAspectRatio, fillOpacity, strokeOpacity)
import Css exposing (asPairs, width, pct)
import Game.Models exposing (GameModel)
import Apps.TaskManager.Messages exposing (Msg(..))
import Apps.TaskManager.Models exposing (..)
import Apps.TaskManager.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "taskmngr"


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style


viewTaskRowUsage : ResourceUsage -> List (Html Msg)
viewTaskRowUsage usage =
    [ div [] [ text ((floatToPrefixedValues usage.cpu) ++ "Hz") ]
    , div [] [ text ((floatToPrefixedValues usage.mem) ++ "iB") ]
    , div [] [ text ((floatToPrefixedValues usage.down) ++ "bps") ]
    , div [] [ text ((floatToPrefixedValues usage.up) ++ "bps") ]
    ]


progressBar : Float -> String -> Html Msg
progressBar percent floatText =
    -- TODO: Make this one into "UI.Widgets"
    node "progressbar"
        []
        [ node "fill"
            [ styles
                [ Css.width
                    (pct
                        (percent * 100)
                    )
                ]
            ]
            []
        , node "label" [] [ text floatText ]
        ]


etaBar : Int -> Int -> Html Msg
etaBar now total =
    progressBar
        (1
            - (toFloat now)
            / (toFloat total)
        )
        (secondsToTimeNotation now)


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

        commonPts =
            (List.indexedMap
                (\i x ->
                    String.concat
                        [ toString ((1 - toFloat (i) / sz) * 3)
                        , ","
                        , toString (1 - x / limit)
                        ]
                )
                history
            )
    in
        div [ class [ Graph ] ]
            [ text title
            , br [] []
            , svg
                [ SvgA.width "100%"
                , SvgA.height "50"
                , viewBox "0 0 3 1"
                ]
                [ polygon
                    [ SvgA.fill color
                    , SvgA.fillOpacity "0.4"
                    , SvgA.stroke "none"
                    , SvgA.points
                        (String.join " "
                            ([ "3,1" ]
                                ++ commonPts
                                ++ [ "0,1" ]
                            )
                        )
                    ]
                    []
                , polyline
                    [ SvgA.fill "none"
                    , SvgA.stroke color
                    , SvgA.strokeOpacity "0.9"
                    , SvgA.strokeWidth "0.02"
                    , SvgA.points
                        (String.join " "
                            commonPts
                        )
                    ]
                    []
                ]
            ]


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
