module Decoders.Network exposing (..)

import Game.Meta.Types.Network as Network exposing (NIP)
import Json.Decode exposing (Decoder, index, string, list)
import Json.Decode.Pipeline exposing (decode, custom, required)


nipTuple : Decoder NIP
nipTuple =
    decode (\network ip -> ( network, ip ))
        |> custom (index 0 string)
        |> custom (index 1 string)


nips : Decoder (List NIP)
nips =
    list nip


nip : Decoder NIP
nip =
    decode Network.toNip
        |> required "network_id" string
        |> required "ip" string
