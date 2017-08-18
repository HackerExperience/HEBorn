module Requests.Requests exposing (request, report, fake)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode
import Driver.Http.Http as HttpDriver
import Driver.Websocket.Channels as WebsocketDriver
import Driver.Websocket.Websocket as WebsocketDriver
import Utils.Cmd as Cmd
import Requests.Topics exposing (..)
import Requests.Types exposing (..)


report : Result String a -> Maybe a
report result =
    case result of
        Ok response ->
            Just response

        Err msg ->
            let
                msg_ =
                    Debug.log ("Request Decode Error " ++ msg) "..."
            in
                Nothing


request :
    Topic
    -> (ResponseType -> msg)
    -> Context
    -> Encode.Value
    -> ConfigSource a
    -> Cmd msg
request topic msg context data source =
    case getDriver topic of
        HttpDriver ->
            requestHttp source.config.apiHttpUrl
                topic
                msg
                context
                data

        WebsocketDriver ->
            requestWebsocket source.config.apiWsUrl
                topic
                msg
                context
                data


fake :
    Topic
    -> (ResponseType -> msg)
    -> Context
    -> Encode.Value
    -> ResponseType
    -> ConfigSource a
    -> Cmd msg
fake _ msg _ _ response _ =
    Cmd.fromMsg (msg response)



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
    case Debug.log "▶ HTTP" result of
        Ok data ->
            msg ( OkCode, toValue data )

        Err (Http.BadStatus response) ->
            msg ( getCode response.status.code, toValue response.body )

        _ ->
            msg ( UnknownErrorCode, emptyPayload )


genericWs : (ResponseType -> msg) -> Encode.Value -> msg
genericWs msg value =
    let
        -- TODO: handle error messages
        decoder =
            decode WebsocketResponse
                |> required "data" Decode.value

        result =
            Decode.decodeValue decoder <| Debug.log "▶ Websocket" value
    in
        case result of
            Ok response ->
                msg ( OkCode, response.data )

            Err str ->
                msg ( Timeout, toValue str )


toValue : String -> Decode.Value
toValue str =
    str
        |> Decode.decodeString Decode.value
        |> Result.withDefault Encode.null
