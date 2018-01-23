module Decoders.BackFlix exposing (..)

import Json.Decode as Decode
    exposing
        ( Decoder
        , map
        , field
        , succeed
        , string
        , float
        , value
        , andThen
        )
import Json.Decode.Pipeline exposing (decode, required, custom)
import Game.BackFlix.Models exposing (..)


log : Decoder Log
log =
    decode Log
        |> custom type_
        |> required "meta" value
        |> required "timestamp" float
        |> required "type" string


type_ : Decoder Type
type_ =
    andThen decodeType <| field "type" string


channel : Decoder String
channel =
    string
        |> field "channel"
        |> field "data"
        |> field "meta"


decodeChannel : String -> Type
decodeChannel channel =
    case channel of
        "account" ->
            JoinAccount

        "server" ->
            JoinServer

        _ ->
            Join


decodeType : String -> Decoder Type
decodeType typename =
    case typename of
        "event" ->
            succeed Event

        "request" ->
            succeed Request

        "receive" ->
            succeed Receive

        "join" ->
            map decodeChannel channel

        "error" ->
            succeed Error

        _ ->
            succeed Other
