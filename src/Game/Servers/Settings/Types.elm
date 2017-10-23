module Game.Servers.Settings.Types exposing (..)

import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder, Value)
import Utils.Ports.Map exposing (Coordinates)


type Configs
    = Location Coordinates
    | Name String


encode : Configs -> Value
encode config =
    case config of
        Location coord ->
            Encode.object
                [ ( "lat", Encode.float coord.lat )
                , ( "lng", Encode.float coord.lng )
                ]

        Name str ->
            Encode.object
                [ ( "name", Encode.string str )
                ]


decodeLocation : Decoder String
decodeLocation =
    Decode.field "address" Decode.string


decodeError : Decoder String
decodeError =
    Decode.field "error" Decode.string
