module Driver.Http.Models exposing (..)

import Http
import Json.Encode
import Json.Decode exposing (Decoder, string, decodeString, int)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Requests.Models
    exposing
        ( Response(ResponseEmpty)
        , RequestPayload
        , RequestTopic(..)
        , RequestID
        , encodeData
        , getResponseCode
        , invalidRequestId
        , ResponseCode(..)
        )
import Core.Messages exposing (CoreMsg(NewResponse))


type alias HttpMsg var =
    { data : var
    }


type alias HttpMsgData =
    Response


invalidHttpMsg : HttpMsg Response
invalidHttpMsg =
    { data = ResponseEmpty
    }


decodeHttpMsgMeta : Decoder (HttpMsg Response)
decodeHttpMsgMeta =
    decode HttpMsg
        |> hardcoded ResponseEmpty


decodeHttpMsg : Decoder a -> Decoder (HttpMsg a)
decodeHttpMsg dataDecoder =
    decode HttpMsg
        |> required "data" (dataDecoder)


encodeHTTPRequest : RequestPayload -> Json.Encode.Value
encodeHTTPRequest payload =
    (encodeData
        payload.args
    )


httpPayloadToString : Json.Encode.Value -> String
httpPayloadToString data =
    Json.Encode.encode 0 data


getTopicPath : RequestTopic -> String
getTopicPath topic =
    case topic of
        TopicAccountLogin ->
            "account/login"

        TopicAccountCreate ->
            "account/register"

        _ ->
            ""


stringToValue : String -> Json.Encode.Value
stringToValue result =
    case (decodeString Json.Decode.value result) of
        Ok m ->
            m

        Err _ ->
            Json.Encode.null


decodeMsg : RequestID -> Result Http.Error String -> CoreMsg
decodeMsg requestId return =
    case return of
        Ok result ->
            NewResponse ( requestId, ResponseCodeOk, stringToValue result )

        Err (Http.BadStatus response) ->
            let
                code =
                    getResponseCode response.status.code

                body =
                    response.body
            in
                NewResponse ( requestId, code, stringToValue body )

        Err reason ->
            let
                d =
                    Debug.log "FIXME: " (toString reason)
            in
                NewResponse
                    ( invalidRequestId
                    , ResponseCodeUnknownError
                    , Json.Encode.null
                    )
