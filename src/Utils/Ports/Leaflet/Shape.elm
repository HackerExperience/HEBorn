module Utils.Ports.Leaflet.Shape
    exposing
        ( Shape
        , Color
        , Size
        , Opacity
        , Lines
        , Latitude
        , Longitude
        , Coordinates
        , polyline
        , antPolyline
        , circle
        , stroke
        , color
        , weight
        , opacity
        , fill
        , fillColor
        , fillOpacity
        , lines
        , radius
        , position
        , rgb
        , coords
        , encode
        )

import Json.Encode as Encode exposing (Value)


{-| Opaque type for shapes, change it with the functions provided here then encode it.
-}
type Shape
    = PolylineShape Path Polyline
    | AntPolylineShape Path AntPolyline
    | CircleShape Path Circle


{-| Specific properties of Polyline.
-}
type alias Polyline =
    { lines : Lines }


{-| Specific properties of AntPolyline.
-}
type alias AntPolyline =
    { lines : Lines
    , pulseColor : Maybe Color
    , delay : Maybe Int
    , dashArray : Maybe DashArray
    }


{-| Specific properties of Circle.
-}
type alias Circle =
    { position : Coordinates, radius : Size }


{-| Generic properties, aplies both `Polyline` and `Circle`.
-}
type alias Path =
    { stroke : Maybe Bool
    , color : Color
    , weight : Maybe Size
    , opacity : Maybe Opacity
    , fill : Maybe Bool
    , fillColor : Maybe Color
    , fillOpacity : Maybe Opacity
    }


{-| Red, green and blue color values.
-}
type alias Color =
    ( Int, Int, Int )


{-| Float value for sizes.
-}
type alias Size =
    Float


{-| Float value for opacity.
-}
type alias Opacity =
    Float


{-| A `List` of `Coordinates`.
-}
type alias Lines =
    List Coordinates


{-| Latitude coordinate.
-}
type alias Latitude =
    Float


{-| Longitude coordinate.
-}
type alias Longitude =
    Float


{-| Latitude and Longitude coordinates.
-}
type alias Coordinates =
    { lat : Latitude
    , lng : Longitude
    }


{-| Latitude and Longitude coordinates.
-}
type alias DashArray =
    ( Int, Int )


{-| Creates a polyline `Shape`, requires position and color
-}
polyline : Lines -> Color -> Shape
polyline lines color =
    PolylineShape (defaultPath color) (defaultPolyline lines)


{-| Creates an antPolyline `Shape`, requires position and color.
-}
antPolyline : Lines -> Color -> Shape
antPolyline lines color =
    AntPolylineShape (defaultPath color) (defaultAntPolyline lines)


{-| Creates a circle `Shape`, requires position, size and color
-}
circle : Coordinates -> Size -> Color -> Shape
circle position size color =
    CircleShape (defaultPath color) (defaultCircle position size)



-- properties


{-| Sets `stroke` property of the `Shape`.
-}
stroke : Maybe Bool -> Shape -> Shape
stroke value shape =
    mapPath shape <| \path -> { path | stroke = value }


{-| Sets `color` property of the `Shape`.
-}
color : Color -> Shape -> Shape
color value shape =
    mapPath shape <| \path -> { path | color = value }


{-| Sets `weight` property of the `Shape`.
-}
weight : Maybe Size -> Shape -> Shape
weight value shape =
    mapPath shape <| \path -> { path | weight = value }


{-| Sets `opacity` property of the `Shape`.
-}
opacity : Maybe Opacity -> Shape -> Shape
opacity value shape =
    mapPath shape <| \path -> { path | opacity = value }


{-| Sets `fill` property of the `Shape`.
-}
fill : Maybe Bool -> Shape -> Shape
fill value shape =
    mapPath shape <| \path -> { path | fill = value }


{-| Sets `fillColor` property of the `Shape`.
-}
fillColor : Maybe Color -> Shape -> Shape
fillColor value shape =
    mapPath shape <| \path -> { path | fillColor = value }


{-| Sets `fillOpacity` property of the `Shape`.
-}
fillOpacity : Maybe Opacity -> Shape -> Shape
fillOpacity value shape =
    mapPath shape <| \path -> { path | fillOpacity = value }


{-| Sets `lines` property of the `Polyline`.
-}
lines : Lines -> Shape -> Shape
lines value shape =
    mapPolyline shape <| \polyline -> { polyline | lines = value }


{-| Sets `radius` property of the `Circle`.
-}
radius : Size -> Shape -> Shape
radius value shape =
    mapCircle shape <| \circle -> { circle | radius = value }


{-| Sets `radius` property of the `Circle`.
-}
position : Coordinates -> Shape -> Shape
position value shape =
    mapCircle shape <| \circle -> { circle | position = value }



-- fields & misc


{-| Creates a `Color` from red, green and blue values.
-}
rgb : Int -> Int -> Int -> Color
rgb =
    (,,)


{-| Creates `Coordinates` from latitude and longitude values.
-}
coords : Float -> Float -> Coordinates
coords =
    Coordinates


{-| Encodes a `Shape` into a `Value`.
-}
encode : Shape -> Value
encode =
    encodeShape >> Encode.object



-- Internals


{-| Create a minimally configured `Path`.
-}
defaultPath : Color -> Path
defaultPath color =
    { stroke = Nothing
    , color = color
    , weight = Nothing
    , opacity = Nothing
    , fill = Nothing
    , fillColor = Nothing
    , fillOpacity = Nothing
    }


{-| Create a minimally configured `Polyline`.
-}
defaultPolyline : Lines -> Polyline
defaultPolyline lines =
    { lines = lines }


{-| Create a minimally configured `Polyline`.
-}
defaultAntPolyline : Lines -> AntPolyline
defaultAntPolyline lines =
    { lines = lines
    , pulseColor = Nothing
    , delay = Nothing
    , dashArray = Nothing
    }


{-| Create a minimally configured `Circle`.
-}
defaultCircle : Coordinates -> Size -> Circle
defaultCircle position size =
    { position = position, radius = size }


{-| Maps `Path` of `Shape`.
-}
mapPath : Shape -> (Path -> Path) -> Shape
mapPath shape apply =
    case shape of
        PolylineShape path polyline ->
            PolylineShape (apply path) polyline

        AntPolylineShape path antPolyline ->
            AntPolylineShape (apply path) antPolyline

        CircleShape path circle ->
            CircleShape (apply path) circle


{-| Maps `Polyline` of `Shape`.
-}
mapPolyline : Shape -> (Polyline -> Polyline) -> Shape
mapPolyline shape apply =
    case shape of
        PolylineShape path polyline ->
            PolylineShape path (apply polyline)

        AntPolylineShape path antPolyline ->
            AntPolylineShape path antPolyline

        CircleShape path circle ->
            CircleShape path circle


{-| Maps `AntPolyline` of `Shape`.
-}
mapAntPolyline : Shape -> (AntPolyline -> AntPolyline) -> Shape
mapAntPolyline shape apply =
    case shape of
        PolylineShape path polyline ->
            PolylineShape path polyline

        AntPolylineShape path antPolyline ->
            AntPolylineShape path (apply antPolyline)

        CircleShape path circle ->
            CircleShape path circle


{-| Maps `Circle` of `Shape`.
-}
mapCircle : Shape -> (Circle -> Circle) -> Shape
mapCircle shape apply =
    case shape of
        PolylineShape path polyline ->
            PolylineShape path polyline

        AntPolylineShape path antPolyline ->
            AntPolylineShape path antPolyline

        CircleShape path circle ->
            CircleShape path (apply circle)


{-| Encodes a `Shape` into a `List (String, Value)`, useful to use with
`Encode.object`.
-}
encodeShape : Shape -> List ( String, Value )
encodeShape shape =
    case shape of
        PolylineShape path polyline ->
            (encodePath path) ++ (encodePolyline polyline)

        AntPolylineShape path antPolyline ->
            (encodePath path) ++ (encodeAntPolyline antPolyline)

        CircleShape path circle ->
            (encodePath path) ++ (encodeCircle circle)


{-| Encodes a `Path` into a `List (String, Value)`, useful to use with
`Encode.object`.
-}
encodePath : Path -> List ( String, Value )
encodePath path =
    List.filterMap identity <|
        [ maybe "stroke" Encode.bool path.stroke
        , Just ( "color", encodeColor path.color )
        , maybe "weight" Encode.float path.weight
        , maybe "opacity" Encode.float path.opacity
        , maybe "fill" Encode.bool path.fill
        , maybe "fillColor" encodeColor path.fillColor
        , maybe "fillOpacity" Encode.float path.fillOpacity
        ]


{-| Encodes a `Color` into a `Value`.
-}
encodeColor : Color -> Value
encodeColor ( r, g, b ) =
    Encode.string <|
        "rgb("
            ++ (toString r)
            ++ ", "
            ++ (toString g)
            ++ ", "
            ++ (toString b)
            ++ ")"


{-| Encodes a `Polyline` into a `List (String, Value)`, useful for
`Encode.object`.
-}
encodePolyline : Polyline -> List ( String, Value )
encodePolyline polyline =
    List.filterMap identity
        [ Just
            ( "lines"
            , polyline.lines
                |> List.map encodeCoordinates
                |> Encode.list
            )
        , Just ( "type", Encode.string "polyline" )
        ]


{-| Encodes an `AntPolyline` into a `List (String, Value)`, useful for
`Encode.object`.
-}
encodeAntPolyline : AntPolyline -> List ( String, Value )
encodeAntPolyline antPolyline =
    List.filterMap identity
        [ Just
            ( "lines"
            , antPolyline.lines
                |> List.map encodeCoordinates
                |> Encode.list
            )
        , Just ( "type", Encode.string "antPolyline" )
        ]


{-| Encode `Coordinates` into `Value`.
-}
encodeCoordinates : Coordinates -> Value
encodeCoordinates { lat, lng } =
    [ lat, lng ]
        |> List.map Encode.float
        |> Encode.list


{-| Encodes a `Circle` into a `List (String, Value)`, useful for
`Encode.object`.
-}
encodeCircle : Circle -> List ( String, Value )
encodeCircle circle =
    List.filterMap identity
        [ Just ( "radius", Encode.float circle.radius )
        , Just ( "type", Encode.string "circle" )
        , Just ( "position", encodeCoordinates circle.position )
        ]


{-| Helper for encoding optional properties.
-}
maybe : String -> (a -> Value) -> Maybe a -> Maybe ( String, Value )
maybe key encode value =
    Maybe.map (encode >> ((,) key)) value
