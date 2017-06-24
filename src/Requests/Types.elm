module Requests.Types
    exposing
        ( Driver(..)
        , Code(..)
        , ConfigSource
        , ResponseType
        , WebsocketResponse
        , Context
        , getCode
        , emptyPayload
        )

import Json.Decode exposing (Value)
import Json.Encode as Encode
import Core.Config exposing (Config)


type alias ConfigSource a =
    { a | config : Config }


type alias ResponseType =
    ( Code, Value )


type alias WebsocketResponse =
    { data : Value }


type Driver
    = WebsocketDriver
    | HttpDriver


type Code
    = OkCode
    | NotFoundCode
    | BadRequestCode
    | UnknownErrorCode


type alias Context =
    Maybe String


getCode : Int -> Code
getCode code =
    case code of
        200 ->
            OkCode

        404 ->
            NotFoundCode

        400 ->
            BadRequestCode

        _ ->
            UnknownErrorCode


emptyPayload : Encode.Value
emptyPayload =
    -- empty payload for request
    Encode.object []
