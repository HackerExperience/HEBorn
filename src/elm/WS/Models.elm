module WS.Models
    exposing
        ( WSMsg
        , WSMsgData
        , WSMsgType(..)
        , invalidWSMsg
        , getWSMsgMeta
        , getWSMsgType
        , decodeWSMsg
        , decodeWSMsgMeta
        , encodeWSRequest
        )

import Json.Encode
import Json.Decode exposing (Decoder, string, decodeString, int)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Requests.Models
    exposing
        ( Response(ResponseEmpty)
        , RequestPayload
        , RequestTopic(..)
        , encodeData
        )


{-| WSMsgType identifies the possible received messages as:

1.  a direct response from a request;
2.  an event broadcasted by the server;
3.  invalid, unexpected format.

-}
type WSMsgType
    = WSResponse
    | WSEvent
    | WSInvalid


type alias WSMsg var =
    { event : String
    , request_id : String
    , data : var
    , code : Int
    }


type alias WSMsgData =
    Response


invalidWSMsg : WSMsg Response
invalidWSMsg =
    { event = "invalid"
    , request_id = "invalid"
    , data = ResponseEmpty
    , code = 400
    }


{-| decodeWsgMeta decodes only the meta part of the msg, it ignores the
"data" field. Useful when we do not know yet what "data" is.
-}
decodeWSMsgMeta : String -> Result String (WSMsg Response)
decodeWSMsgMeta =
    decodeString
        (decode WSMsg
            |> optional "event" string "request"
            |> optional "request_id" string "event"
            |> hardcoded ResponseEmpty
            |> required "code" int
        )


{-| decodeWSMsg will decode a raw string into the expected WSMsg format.
-}
decodeWSMsg : Decoder a -> Decoder (WSMsg a)
decodeWSMsg dataDecoder =
    decode WSMsg
        |> optional "event" string "request"
        |> optional "request_id" string "event"
        |> required "data" (dataDecoder)
        |> required "code" int


encodeWSRequest : RequestPayload -> String
encodeWSRequest payload =
    let
        topic =
            getTopicChannel payload.topic
    in
        Json.Encode.encode 0
            (Json.Encode.object
                [ ( "topic", Json.Encode.string topic )
                , ( "args", encodeData payload.args )
                , ( "request_id", Json.Encode.string payload.request_id )
                ]
            )


{-| getWSMsgType is used to quickly tell us the type of the received message,
as defined by WSMsgType (response, event or invalid).
-}
getWSMsgType : WSMsg WSMsgData -> WSMsgType
getWSMsgType msg =
    case msg.request_id of
        "event" ->
            WSEvent

        "invalid" ->
            WSInvalid

        _ ->
            WSResponse



{- getWSMsg gets the raw WS message we just received and converts it to a
   format complying with WSMsg type. If it fails, we return a WSMsg JSON with
   invalid data.
-}


getWSMsgMeta : String -> WSMsg WSMsgData
getWSMsgMeta msg =
    case decodeWSMsgMeta msg of
        Ok msg ->
            let
                debug1 =
                    Debug.log "msg: " (toString msg)
            in
                msg

        Err reason ->
            let
                debug1 =
                    Debug.log "invalid payload: " (toString msg)

                debug2 =
                    Debug.log "reason: " (toString reason)
            in
                invalidWSMsg


getTopicChannel : RequestTopic -> String
getTopicChannel topic =
    case topic of
        TopicAccountLogin ->
            "account:login"

        TopicAccountCreate ->
            "account:create"
