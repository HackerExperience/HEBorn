module Decoders.Network exposing (..)

import Dict exposing (Dict)
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Meta.Types.Network.Connections as Connections
    exposing
        ( Connection
        , Connections
        )
import Json.Decode exposing (Decoder, index, bool, string, list, map)
import Json.Decode.Pipeline exposing (decode, custom, required)


connections : Decoder Connections
connections =
    map Dict.fromList <| list connection


connection : Decoder ( Connections.Id, Connection )
connection =
    let
        connection =
            decode Connection
                |> required "name" string
                |> required "used?" bool
    in
        decode (,)
            |> custom nip
            |> custom connection


nipTuple : Decoder NIP
nipTuple =
    decode (,)
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
