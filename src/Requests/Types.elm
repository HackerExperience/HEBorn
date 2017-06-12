module Requests.Types
    exposing
        ( Driver(..)
        , Code(..)
        , ResponseType
        , Context
        , getCode
        )


type alias ResponseType =
    ( Code, String )


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
