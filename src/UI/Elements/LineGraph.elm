module UI.Elements.LineGraph exposing (lineGraph)

import Html exposing (Html)
import Svg exposing (svg, polyline, polygon)
import Svg.Attributes
    exposing
        ( width
        , height
        , viewBox
        , fill
        , fillOpacity
        , stroke
        , strokeOpacity
        , strokeWidth
        , points
        )
import UI.ToString exposing (pointToSvgAttr)


lineGraph : List ( Float, Float ) -> String -> Int -> Bool -> ( Float, Float ) -> Html msg
lineGraph values color height_ fromRight (( aspect_w, aspect_h ) as aspect) =
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
            [ width "100%"
            , height (toString height_)
            , viewBox viewBoxStr
            ]
            [ polygon
                [ fill color
                , fillOpacity "0.4"
                , stroke "none"
                , points <| String.join " " <| first :: (points_ ++ [ last ])
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
