module Game.Servers.Settings.Types
    exposing
        ( Settings(..)
        , encode
        , decodeLocation
        , decodeError
        )

import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder, Value)
import Utils.Ports.Map exposing (Coordinates)


type Settings
    = Location Coordinates
    | Name String



-- encoder


encode : Settings -> Value
encode config =
    case config of
        Location coord ->
            encodeLocation coord

        Name name ->
            encodeName name



-- decoders


decodeLocation : Decoder String
decodeLocation =
    Decode.field "address" Decode.string


decodeError : Decoder String
decodeError =
    Decode.field "error" Decode.string



-- internals


encodePayload : String -> Value -> Value
encodePayload name value =
    Encode.object
        [ ( "key", Encode.string name )
        , ( "value", value )
        ]


encodeLocation : Coordinates -> Value
encodeLocation { lat, lng } =
    encodePayload "coordinates" <|
        Encode.object
            [ ( "lat", Encode.float lat )
            , ( "lng", Encode.float lng )
            ]


encodeName : String -> Value
encodeName name =
    encodePayload "coordinates" <|
        Encode.object
            [ ( "name", Encode.string name )
            ]
