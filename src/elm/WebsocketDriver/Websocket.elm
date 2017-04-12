module WebsocketDriver.Websocket exposing (send)

import WebSocket


{-| send the message (string, already json-encoded) to the Helix server.
-}
send : String -> Cmd msg
send payload =
    WebSocket.send "ws://localhost:8080" payload
