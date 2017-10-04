module Decoders.Tunnels exposing (..)

import Dict exposing (Dict)
import Utils.Json.Decode exposing (optionalMaybe)
import Json.Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , maybe
        , string
        , list
        , map
        )
import Json.Decode.Pipeline exposing (decode, optional, required, custom)
import Game.Servers.Tunnels.Models exposing (..)


type alias Index =
    List ( ID, Tunnel )


model : Decoder Model
model =
    map Dict.fromList (list tunnelWithId)


index : Decoder Index
index =
    list tunnelWithId


tunnelWithId : Decoder ( ID, Tunnel )
tunnelWithId =
    decode (,)
        |> custom id
        |> custom (map Tunnel connections)


id : Decoder ID
id =
    decode (,,)
        |> optional "bounce_id" string ""
        |> required "network_id" string
        |> required "ip" string


connections : Decoder Connections
connections =
    map Dict.fromList (list connectionWithId)


connectionWithId : Decoder ( ConnectionID, Connection )
connectionWithId =
    decode (,)
        |> required "id" string
        |> custom connection


connection : Decoder Connection
connection =
    decode Connection
        |> required "type" connectionType


connectionType : Decoder ConnectionType
connectionType =
    map toConnectionType string
