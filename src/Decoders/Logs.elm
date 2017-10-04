module Decoders.Logs exposing (..)

import Dict exposing (Dict)
import Game.Servers.Logs.Models exposing (..)
import Json.Decode as Decode exposing (Decoder, map, string, float, list)
import Json.Decode.Pipeline exposing (decode, required, optional, custom)
import Time exposing (Time)


type alias Index =
    List ( ID, Log )


model : Decoder Model
model =
    map Dict.fromList index


index : Decoder Index
index =
    list logWithId


logWithId : Decoder ( ID, Log )
logWithId =
    decode (,)
        |> required "log_id" string
        |> custom (map (\a -> a Normal) log)


log : Decoder (Status -> Log)
log =
    decode (\c t s -> Log t s c)
        |> optional "message" (map Uncrypted data) Encrypted
        |> required "inserted_at" float


data : Decoder Data
data =
    map dataFromString string
