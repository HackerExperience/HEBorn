module Decoders.Network exposing (..)

import Game.Network.Types exposing (NIP)
import Json.Decode exposing (Decoder, index, string)
import Json.Decode.Pipeline exposing (decode, custom)


nip : Decoder NIP
nip =
    decode (\network ip -> ( network, ip ))
        |> custom (index 0 string)
        |> custom (index 1 string)
