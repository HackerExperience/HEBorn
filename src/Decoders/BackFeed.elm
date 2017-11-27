module Decoders.BackFeed exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
    exposing
        ( Decoder
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
        decodedField =
            field "type" string

        decodeType typename =
            case typename of
                "event" ->
                    succeed Event

                "request" ->
                    succeed Request

                "receive" ->
                    succeed Receive

                "join" ->
                    succeed Join

                "error" ->
                    succeed Error

                _ ->
                    succeed Other
    in
        andThen decodeType decodedField
