module Requests.Types
    exposing
        ( Driver(..)
        , Code(..)
        , ResponseType
        , WebsocketResponse
        , Context
        , getCode
        , emptyPayload
        )

import Json.Decode
import Json.Encode as Encode


type alias ResponseType =
    ( Code, String )


type alias WebsocketResponse =
    { data : Json.Decode.Value }


type Driver
    = WebsocketDriver
    | HttpDriver


type Code
    = OkCode
    | NotFoundCode
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

        _ ->
            UnknownErrorCode


emptyPayload : Encode.Value
emptyPayload =
    -- empty payload for request
    Encode.object []
