module Decoders.BackFeed exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , map
        , field
        , oneOf
        , succeed
        , string
        , float
        , fail
        , list
        , value
        , andThen
        )
import Json.Decode.Pipeline exposing (decode, required, optional, custom, hardcoded)
import Game.BackFeed.Models as BackFeed exposing (..)
import Utils.Json.Decode exposing (commonError)
import Core.Error as Error


backlog : Decoder BackLog
backlog =
    decode BackLog
        |> custom type_
        |> required "meta" value
        |> required "timestamp" float
        |> required "type" string


type_ : Decoder Type
type_ =
    let
        channel =
            string
                |> field "channel"
                |> field "data"
                |> field "meta"

        decodeChannel channel =
            case channel of
                "account" ->
                    JoinAccount

                "server" ->
                    JoinServer

                _ ->
                    Join

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
    in
        andThen decodeType <| field "type" string
