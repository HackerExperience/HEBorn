module Requests.Requests exposing (request, report, decodeGenericError)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode
import Driver.Http.Http as HttpDriver
import Driver.Websocket.Channels as WebsocketDriver
import Driver.Websocket.Websocket as WebsocketDriver
import Requests.Topics as Topics exposing (Topic(..))
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
    -> Encode.Value
    -> FlagsSource a
    -> Cmd msg
request topic msg data source =
    case topic of
        WebsocketTopic channel path ->
            WebsocketDriver.send
                (okWs msg)
                (errorWs msg)
                source.flags.apiWsUrl
                (WebsocketDriver.getAddress channel)
                path
                data

        HttpTopic path ->
            HttpDriver.send (genericHttp msg)
                source.flags.apiHttpUrl
                path
                (Encode.encode 0 data)


decodeGenericError :
    Decode.Value
    -> (String -> Decode.Decoder a)
    -> Maybe a
decodeGenericError value decodeMessage =
    Decode.field "message" Decode.string
        |> Decode.andThen decodeMessage
        |> flip Decode.decodeValue value
        |> report



-- internals


genericHttp : (ResponseType -> msg) -> Result Http.Error String -> msg
genericHttp msg result =
    case Debug.log "▶ HTTP" result of
        Ok data ->
            msg ( OkCode, toValue data )

        Err (Http.BadStatus response) ->
            msg ( getCode response.status.code, toValue response.body )

        _ ->
            msg ( UnknownErrorCode, emptyPayload )


okWs : (ResponseType -> msg) -> Encode.Value -> msg
okWs msg value =
    let
        result =
            value
                |> Debug.log "▶ Websocket (:ok)"
                |> Decode.decodeValue response
    in
        case result of
            Ok response ->
                msg ( OkCode, response.data )

            Err str ->
                msg ( Timeout, toValue str )


errorWs : (ResponseType -> msg) -> Encode.Value -> msg
errorWs msg value =
    let
        result =
            value
                |> Debug.log "▶ Websocket (:error)"
                |> Decode.decodeValue response
    in
        case result of
            Ok response ->
                msg ( ErrorCode, response.data )

            Err str ->
                msg ( Timeout, toValue str )


response : Decode.Decoder WebsocketResponse
response =
    decode WebsocketResponse
        |> required "data" Decode.value


toValue : String -> Decode.Value
toValue str =
    str
        |> Decode.decodeString Decode.value
        |> Result.withDefault Encode.null
