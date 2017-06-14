module UI.Widgets exposing (..)

import Html exposing (..)
import Html.Attributes as Html exposing (style)
import Html.CssHelpers
import Css exposing (asPairs, width, minHeight, fontSize, lineHeight, pct, px, int)
import Svg exposing (svg, polyline, polygon)
import Svg.Attributes as Svg exposing (..)
import UI.ToString exposing (pointToSvgAttr)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "ui"


styles : List Css.Mixin -> Attribute msg
styles =
    Css.asPairs >> Html.style


progressBar : Float -> String -> Float -> Html msg
progressBar percent floatText height =
    node "progressbar"
        [ styles [ Css.minHeight (px height) ] ]
        [ node "fill"
            [ styles
                [ Css.width
                    (pct
                        (percent * 100)
                    )
                , Css.lineHeight (int 1)
                , Css.fontSize (px height)
                ]
            ]
            []
        , node "label" [] [ text floatText ]
        ]


lineGraph : List ( Float, Float ) -> String -> Int -> Bool -> ( Float, Float ) -> Html msg
lineGraph values color height fromRight (( aspect_w, aspect_h ) as aspect) =
    let
        viewBoxValue =
            [ 0, 0, aspect_w, aspect_h ]

        viewBoxStr =
            viewBoxValue |> List.map toString |> String.join " "

        bottomRight =
            ( aspect_w, aspect_h )

        bottomLeft =
            ( 0, aspect_h )

        first =
            (pointToSvgAttr
                (if fromRight then
                    bottomRight
                 else
                    bottomLeft
                )
            )

        last =
            (pointToSvgAttr
                (if fromRight then
                    bottomLeft
                 else
                    bottomRight
                )
            )

        toAspect =
            \( aspect_w, aspect_h ) ( x, y ) -> ( x * aspect_w, y * aspect_h )

        points_ =
            List.map ((toAspect aspect) >> pointToSvgAttr) values
    in
        svg
            [ Svg.width "100%"
            , Svg.height (toString height)
            , viewBox viewBoxStr
            ]
            [ polygon
                [ fill color
                , fillOpacity "0.4"
                , stroke "none"
                , points
                    (String.join " "
                        ([ first ]
                            ++ points_
                            ++ [ last ]
                        )
                    )
                ]
                []
            , polyline
                [ fill "none"
                , stroke color
                , strokeOpacity "0.9"
                , strokeWidth "0.02"
                , points
                    (String.join " "
                        points_
                    )
                ]
                []
            ]
