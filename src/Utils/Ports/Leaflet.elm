port module Utils.Ports.Leaflet
    exposing
        ( Id
        , Latitude
        , Longitude
        , Coordinates
        , Zoom
        , Msg(..)
        , init
        , center
        , insertProjection
        , removeProjection
        , setShape
        , removeShape
        , subscribe
        )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Json.Decode.Pipeline exposing (decode, required)
import Utils.Json.Decode exposing (commonError)
import Utils.Ports.Leaflet.Shape as Shape exposing (Shape)


{-| Map Id.
-}
type alias Id =
    String


{-| Projection point name.
-}
type alias Name =
    String


{-| Latitude coordinate.
-}
type alias Latitude =
    Shape.Latitude


{-| Longitude coordinate.
-}
type alias Longitude =
    Shape.Longitude


{-| Map coordinates.
-}
type alias Coordinates =
    Shape.Coordinates


{-| 2D Point in the map.
-}
type alias Point =
    { x : Float
    , y : Float
    }


{-| Map zoom level.
-}
type alias Zoom =
    Float


{-| Messages received from Leaflet.
-}
type Msg
    = Clicked Coordinates
    | Moved Point
    | Projected Name Point
    | Unknown


type LeafletCmd
    = Init
    | InsertProjection Name Coordinates
    | RemoveProjection Name
    | SetShape Name Shape
    | RemoveShape Name
    | Center Coordinates Zoom


{-| Initializes Leaflet map.
-}
init : Id -> Cmd msg
init id =
    Init
        |> cmd id
        |> leafletCmd


{-| Centers given Leaflet map.
-}
center : Id -> Coordinates -> Zoom -> Cmd msg
center id coordinates zoom =
    zoom
        |> Center coordinates
        |> cmd id
        |> leafletCmd


{-| Adds a new coordinate projection to watch.
-}
insertProjection : Id -> Name -> Coordinates -> Cmd msg
insertProjection id name coordinates =
    coordinates
        |> InsertProjection name
        |> cmd id
        |> leafletCmd


{-| Stops watching a coordinate projection.
-}
removeProjection : Id -> Name -> Cmd msg
removeProjection id name =
    name
        |> RemoveProjection
        |> cmd id
        |> leafletCmd


{-| Creates or updates a `Shape`.
-}
setShape : Id -> Name -> Shape -> Cmd msg
setShape id name shape =
    shape
        |> SetShape name
        |> cmd id
        |> leafletCmd


{-| Removes updates a `Shape`.
-}
removeShape : Id -> Name -> Cmd msg
removeShape id name =
    name
        |> RemoveShape
        |> cmd id
        |> leafletCmd


{-| Subscribes to Leaflet.
-}
subscribe : (Id -> Msg -> msg) -> Sub msg
subscribe toMsg =
    leafletSub <|
        \value ->
            case Decode.decodeValue sub value of
                Ok ( id, sub ) ->
                    toMsg id sub

                Err msg ->
                    let
                        _ =
                            Debug.log "Leaflet communication error" msg
                    in
                        toMsg "" Unknown



-- internals


port leafletSub : (Decode.Value -> msg) -> Sub msg


port leafletCmd : Encode.Value -> Cmd msg


cmd : Id -> LeafletCmd -> Encode.Value
cmd id leafCmd =
    case leafCmd of
        Init ->
            Encode.object
                [ ( "id", Encode.string id )
                , ( "msg", Encode.string "init" )
                ]

        Center { lat, lng } zoom ->
            Encode.object
                [ ( "id", Encode.string id )
                , ( "msg", Encode.string "center" )
                , ( "lat", Encode.float lat )
                , ( "lng", Encode.float lng )
                , ( "zoom", Encode.float zoom )
                ]

        InsertProjection name { lat, lng } ->
            Encode.object
                [ ( "id", Encode.string id )
                , ( "msg", Encode.string "insertProjection" )
                , ( "name", Encode.string name )
                , ( "lat", Encode.float lat )
                , ( "lng", Encode.float lng )
                ]

        RemoveProjection name ->
            Encode.object
                [ ( "id", Encode.string id )
                , ( "msg", Encode.string "removeProjection" )
                , ( "name", Encode.string name )
                ]

        SetShape name shape ->
            Encode.object
                [ ( "id", Encode.string id )
                , ( "msg", Encode.string "setShape" )
                , ( "name", Encode.string name )
                , ( "shape", Shape.encode shape )
                ]

        RemoveShape name ->
            Encode.object
                [ ( "id", Encode.string id )
                , ( "msg", Encode.string "removeShape" )
                , ( "name", Encode.string name )
                ]


sub : Decoder ( Id, Msg )
sub =
    Decode.string
        |> Decode.field "msg"
        |> Decode.andThen
            (\t ->
                case t of
                    "clicked" ->
                        decode Shape.Coordinates
                            |> required "lat" Decode.float
                            |> required "lng" Decode.float
                            |> Decode.map Clicked
                            |> Decode.map (flip (,))
                            |> required "id" Decode.string

                    "moved" ->
                        decode Point
                            |> required "x" Decode.float
                            |> required "y" Decode.float
                            |> Decode.map Moved
                            |> Decode.map (flip (,))
                            |> required "id" Decode.string

                    "projected" ->
                        decode Point
                            |> required "x" Decode.float
                            |> required "y" Decode.float
                            |> Decode.map (flip Projected)
                            |> required "name" Decode.string
                            |> Decode.map (flip (,))
                            |> required "id" Decode.string

                    _ ->
                        Decode.fail <| commonError "msg" t
            )
