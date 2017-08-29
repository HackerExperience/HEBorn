module Game.Network.Types exposing (..)

import Json.Decode exposing (Decoder, index, string)
import Json.Decode.Pipeline exposing (decode, custom)

type alias IP =
    String


type alias ID =
    String


type alias NIP =
    ( ID, IP )


type alias StringifiedNIP =
    String


toString : NIP -> StringifiedNIP
toString ( id, ip ) =
    id ++ "," ++ ip


fromString : StringifiedNIP -> NIP
fromString str =
    case String.split "," str of
        [ id, ip ] ->
            ( id, ip )

        _ ->
            ( "::", "" )

decodeNip : Decoder ( String, String )
decodeNip =
    decode (\network ip -> ( network, ip ))
        |> custom (index 0 string)
        |> custom (index 1 string)
