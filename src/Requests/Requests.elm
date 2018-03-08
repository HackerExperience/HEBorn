module Requests.Requests exposing (request, report)

import Http
import Utils.Json.Decode as Decode
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode
import Driver.Http.Http as HttpDriver
import Driver.Websocket.Channels as WebsocketDriver
import Driver.Websocket.Websocket as WebsocketDriver
import Requests.Topics as Topics exposing (Topic(..))
import Requests.Types exposing (..)


request : Topic -> Encode.Value -> FlagsSource a -> Cmd ResponseType
request topic payload flagSource =
    case topic of
        WebsocketTopic channel path ->
            WebsocketDriver.send
                (okWs identity)
                (errorWs identity)
                flagSource.flags.apiWsUrl
                (WebsocketDriver.getAddress channel)
                path
                payload

        HttpTopic path ->
            HttpDriver.send (genericHttp identity)
                flagSource.flags.apiHttpUrl
                path
                (Encode.encode 0 payload)


report : String -> Code -> FlagsSource a -> Result String b -> Result String b
report info code flagSrc result =
    Decode.report ("Request (" ++ toString code ++ ") " ++ info)
        flagSrc.flags
        result



-- internals----


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
