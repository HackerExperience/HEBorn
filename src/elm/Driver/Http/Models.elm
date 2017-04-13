module Driver.Http.Models exposing (..)

import Dict
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
        )


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


getRequestIdHeader : Dict.Dict String RequestID -> Maybe RequestID
getRequestIdHeader headers =
    Dict.get "X-Request-Id" headers


getTopicUrl : RequestTopic -> String
getTopicUrl topic =
    case topic of
        TopicAccountLogin ->
            "account/login"

        TopicAccountCreate ->
            "account/register"

        _ ->
            ""
