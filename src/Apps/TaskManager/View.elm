module Apps.TaskManager.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.CssHelpers
import Svg exposing (svg, polyline, polygon)
import Svg.Attributes as SvgA exposing (width, height, viewBox, fill, stroke, strokeWidth, points, preserveAspectRatio, fillOpacity, strokeOpacity)
import Css exposing (asPairs)
import Game.Models exposing (GameModel)
import Apps.TaskManager.Messages exposing (Msg(..))
import Apps.TaskManager.Models exposing (..)
import Apps.TaskManager.Menu.View exposing (menuView)
import Apps.TaskManager.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "taskmngr"


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style


toPrefixedValues : Float -> String
toPrefixedValues x =
    -- TODO: Move this function to a better place
    -- TODO: Use "round 2" from elm-round
    if (x > (10 ^ 9)) then
        toString (x / (10 ^ 9)) ++ " G"
    else if (x > (10 ^ 6)) then
        toString (x / (10 ^ 6)) ++ " M"
    else if (x > (10 ^ 3)) then
        toString (x / (10 ^ 3)) ++ " K"
    else
        toString (x) ++ " "


toTimeNotation : Int -> String
toTimeNotation count =
    if (count > 3600) then
        let
            h =
                (toString (count // 3600))

            l =
                (count % 3600)

            m =
                (toString (l // 60))

            s =
                (toString (l % 60))
        in
            h ++ "h" ++ m ++ "m" ++ s ++ "s"
    else if (count > 60) then
        let
            m =
                (toString (count // 60))

            s =
                (toString (count % 60))
        in
            m ++ "m" ++ s ++ "s"
    else
        (toString count) ++ "s"


viewTaskRowUsage : ResourceUsage -> List (Html Msg)
viewTaskRowUsage usage =
    [ div [] [ text ((toPrefixedValues usage.cpu) ++ "Hz") ]
    , div [] [ text ((toPrefixedValues usage.mem) ++ "iB") ]
    , div [] [ text ((toPrefixedValues usage.down) ++ "bps") ]
    , div [] [ text ((toPrefixedValues usage.up) ++ "bps") ]
    ]


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
        , div []
            [ text
                (toString
                    (1
                        - (toFloat entry.etaNow)
                        / (toFloat entry.etaTotal)
                    )
                )
            , br [] []
            , text (toTimeNotation entry.etaNow)
            ]
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
                        [ toString (1 - toFloat (i) / sz)
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
                , SvgA.preserveAspectRatio "none"
                , viewBox "0 0 1 1"
                ]
                [ polygon
                    [ SvgA.fill color
                    , SvgA.fillOpacity "0.4"
                    , SvgA.stroke "none"
                    , SvgA.points
                        (String.join " "
                            ([ "1,1" ]
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
