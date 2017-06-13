module Requests.Requests exposing (request, report)

import Core.Config exposing (Config)
import Result as Result exposing (Result(..))
import Http
import Driver.Http.Http as HttpDriver
import Driver.Websocket.Channels as WebsocketDriver
import Driver.Websocket.Websocket as WebsocketDriver
import Requests.Types exposing (..)
import Requests.Topics exposing (..)
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)


report : Result String a -> a
report result =
    case result of
        Ok response ->
            response

        Err _ ->
            Debug.crash "Failed to decode response from server"


request :
    Topic
    -> (ResponseType -> msg)
    -> Context
    -> Encode.Value
    -> Config
    -> Cmd msg
request topic msg context data config =
    case getDriver topic of
        HttpDriver ->
            requestHttp config.apiHttpUrl
                topic
                msg
                context
                data

        WebsocketDriver ->
            requestWebsocket config.apiWsUrl
                topic
                msg
                context
                data



-- internals


requestHttp :
    String
    -> Topic
    -> (ResponseType -> msg)
    -> Context
    -> Encode.Value
    -> Cmd msg
requestHttp url topic msg context data =
    data
        |> Encode.encode 0
        |> HttpDriver.send
            (genericHttp msg)
            url
            (getHttpPath topic)


requestWebsocket :
    String
    -> Topic
    -> (ResponseType -> msg)
    -> Context
    -> Encode.Value
    -> Cmd msg
requestWebsocket url topic msg context data =
    let
        channelAddress =
            WebsocketDriver.getAddress (getChannel topic) context
    in
        data
            |> WebsocketDriver.send
                (genericWs msg)
                url
                channelAddress
                (getWebsocketMsg topic)


genericHttp : (ResponseType -> msg) -> Result Http.Error String -> msg
genericHttp msg result =
    case result of
        Ok data ->
            msg ( OkCode, data )

        Err (Http.BadStatus response) ->
            msg ( getCode response.status.code, response.body )

        _ ->
            Debug.crash "Http Driver failure"


genericWs : (ResponseType -> msg) -> Encode.Value -> msg
genericWs msg value =
    let
        -- TODO: handle error messages
        decoder =
            decode WebsocketResponse
                |> required "data" Decode.value

        result =
            Decode.decodeValue decoder value
    in
        case result of
            Ok response ->
                msg ( OkCode, toString response.data )

            Err _ ->
                msg ( UnknownErrorCode, "" )
