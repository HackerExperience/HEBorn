module WS.Models
    exposing
        ( WSMsg
        , WSMsgData
        , WSMsgType(..)
        , invalidWSMsg
        , decodeWSMsg
        , decodeWSMsgMeta
        )

import Json.Decode exposing (Decoder, string, decodeString, int)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Requests.Models exposing (Response(ResponseEmpty))


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
