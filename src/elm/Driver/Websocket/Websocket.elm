module Driver.Websocket.Websocket exposing (send)

import WebSocket


{-| send the message (string, already json-encoded) to the Helix server.
-}
send : String -> Cmd msg
send payload =
    Cmd.none



-- WebSocket.send "ws://localhost:4000" payload
