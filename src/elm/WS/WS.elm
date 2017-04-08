module WS.WS exposing (getWSMsgMeta, send, getWSMsgType)

import WebSocket
import WS.Models exposing (WSMsg, WSMsgData, WSMsgType(..), invalidWSMsg, decodeWSMsgMeta)


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


{-| send the message (string, already json-encoded) to the Helix server.
-}
send : String -> Cmd msg
send payload =
    WebSocket.send "ws://localhost:8080" payload
