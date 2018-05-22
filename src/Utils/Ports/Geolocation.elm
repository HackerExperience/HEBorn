port module Utils.Ports.Geolocation
    exposing
        ( Id
        , Latitude
        , Longitude
        , Coords
        , Msg(..)
        , getCoordinates
        , getLabel
        , subscribe
        )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Json.Decode.Pipeline exposing (decode, required)
import Utils.Json.Decode exposing (commonError)


{-| Geolocation requester Id.
-}
type alias Id =
    String


{-| Latitude coordinate.
-}
type alias Latitude =
    Float


{-| Longitude coordinate.
-}
type alias Longitude =
    Float


{-| Latitude and longitude coordinates.
-}
type alias Coords =
    { lat : Latitude
    , lng : Longitude
    }


{-| Messages received from Geolocation.
-}
type Msg
    = Coordinates Coords
    | Label String
    | Unknown


type GeolocationCmd
    = GetCoordinates
    | GetLabel Coords


{-| Asks for current Geolocation.
-}
getCoordinates : Id -> Cmd msg
getCoordinates id =
    GetCoordinates
        |> cmd id
        |> geolocationCmd


{-| Asks label for given Geolocation.
-}
getLabel : Id -> Coords -> Cmd msg
getLabel id coords =
    coords
        |> GetLabel
        |> cmd id
        |> geolocationCmd


{-| Subscribes to Geolocation.
-}
subscribe : (Id -> Msg -> msg) -> Sub msg
subscribe toMsg =
    geolocationSub <|
        \value ->
            case Decode.decodeValue sub value of
                Ok ( id, sub ) ->
                    toMsg id sub

                Err msg ->
                    let
                        _ =
                            Debug.log "Geolocation communication error" msg
                    in
                        toMsg "" Unknown



-- internals


port geolocationSub : (Decode.Value -> msg) -> Sub msg


port geolocationCmd : Encode.Value -> Cmd msg


cmd : Id -> GeolocationCmd -> Encode.Value
cmd id geoCmd =
    case geoCmd of
        GetCoordinates ->
            Encode.object
                [ ( "msg", Encode.string "coordinates" )
                , ( "id", Encode.string id )
                ]

        GetLabel { lat, lng } ->
            Encode.object
                [ ( "msg", Encode.string "label" )
                , ( "id", Encode.string id )
                , ( "lat", Encode.float lat )
                , ( "lng", Encode.float lng )
                ]


sub : Decoder ( Id, Msg )
sub =
    Decode.string
        |> Decode.field "msg"
        |> Decode.andThen
            (\t ->
                case t of
                    "coordinates" ->
                        decode Coords
                            |> required "lat" Decode.float
                            |> required "lng" Decode.float
                            |> Decode.map (Coordinates >> flip (,))
                            |> required "id" Decode.string

                    "label" ->
                        decode Label
                            |> required "label" Decode.string
                            |> Decode.map (flip (,))
                            |> required "id" Decode.string

                    _ ->
                        Decode.fail <| commonError "msg" t
            )
