module Decoders.Logs exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
    exposing
        ( Decoder
        , map
        , oneOf
        , succeed
        , string
        , float
        , list
        , andThen
        )
import Time exposing (Time)
import Json.Decode.Pipeline exposing (decode, required, optional, custom, hardcoded)
import Game.Servers.Logs.Models exposing (..)


type alias Index =
    List LogWithIndex


type alias LogWithIndex =
    ( ID, Log )


model : Decoder Model
model =
    let
        logs =
            map Dict.fromList index

        drawOrder =
            map (Dict.foldl reducer Dict.empty) logs

        reducer id log acu =
            Dict.insert (findId ( log.timestamp, 0 ) acu) id acu
    in
        decode Model
            |> custom logs
            |> custom drawOrder


index : Decoder Index
index =
    list logWithId


logWithId : Decoder ( ID, Log )
logWithId =
    decode (,)
        |> required "log_id" string
        |> custom log


log : Decoder Log
log =
    decode Log
        |> required "timestamp" float
        |> hardcoded Normal
        |> required "message" (string |> map content)


content : String -> Content
content src =
    src
        |> dataFromSever
        |> NormalContent


data : Decoder Data
data =
    map dataFromString string



-- internals


dataFromSever : String -> Data
dataFromSever raw =
    Data raw <|
        case String.split " " raw of
            [ "localhost", "logged", "into", target ] ->
                if (ipValid target) then
                    RemoteLogin target
                        |> RemoteLoginFormat
                        |> Just
                else
                    Nothing

            _ ->
                Nothing
