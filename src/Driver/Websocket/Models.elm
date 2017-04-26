module Driver.Websocket.Models
    exposing
        ( Model
        , initialModel
        , WSMsg
        , WSMsgData
        , WSMsgType(..)
        , invalidWSMsg
        , getWSMsgMeta
        , getWSMsgType
        , decodeWSMsg
        , decodeWSMsgMeta
        , encodeWSRequest
        , getTopicMsg
        , getTopicChannel
        , getChannelAddress
        , getResponse
        )

import Json.Encode
import Json.Decode exposing (Decoder, string, decodeString, int, decodeValue, Value)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Requests.Models
    exposing
        ( Response(ResponseEmpty)
        , RequestPayload
        , RequestTopic(..)
        , TopicContext
        , ResponseCode
        , encodeData
        , getResponseCode
        )
import Driver.Websocket.Messages exposing (Msg(..))
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel


type alias Model =
    { socket : Socket.Socket Msg
    , channels : List (Channel.Channel Msg)
    , defer : Bool
    }


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
    Json.Encode.Value


type Channel
    = ChannelAccount
    | ChannelRequests


initialSocket : String -> Socket.Socket Msg
initialSocket apiWsUrl =
    Socket.init apiWsUrl


initialChannels : List (Channel.Channel Msg)
initialChannels =
    [ Channel.init "requests" ]


initialModel : String -> Model
initialModel apiWsUrl =
    { socket = initialSocket apiWsUrl
    , channels = initialChannels
    , defer = True
    }


invalidWSMsg : WSMsg Json.Encode.Value
invalidWSMsg =
    { event = "invalid"
    , request_id = "invalid"
    , data = Json.Encode.null
    , code = 400
    }


{-| decodeWsgMeta decodes only the meta part of the msg, it ignores the
"data" field. Useful when we do not know yet what "data" is.
-}
decodeWSMsgMeta : Json.Decode.Value -> Result String (WSMsg WSMsgData)
decodeWSMsgMeta =
    decodeValue
        (decode WSMsg
            |> optional "event" string "request"
            |> optional "request_id" string "event"
            |> required "data" Json.Decode.value
            |> optional "code" int 0
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


encodeWSRequest : RequestPayload -> Json.Encode.Value
encodeWSRequest payload =
    encodeData
        payload.args


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


getWSMsgMeta : Json.Decode.Value -> WSMsg WSMsgData
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


getTopicMsg : RequestTopic -> String
getTopicMsg topic =
    case topic of
        TopicAccountLogin ->
            "account.login"

        TopicAccountCreate ->
            "account.create"

        TopicAccountLogout ->
            "account.get"


getTopicChannel : RequestTopic -> Channel
getTopicChannel topic =
    case topic of
        TopicAccountLogin ->
            ChannelAccount

        TopicAccountCreate ->
            ChannelAccount

        TopicAccountLogout ->
            ChannelRequests


getChannelAddress : Channel -> TopicContext -> String
getChannelAddress channel context =
    case channel of
        ChannelAccount ->
            "account:" ++ context

        ChannelRequests ->
            "requests"


getResponse : Json.Decode.Value -> ( WSMsg WSMsgData, ResponseCode )
getResponse msg =
    let
        meta =
            getWSMsgMeta msg

        code =
            getResponseCode meta.code
    in
        ( meta, code )
