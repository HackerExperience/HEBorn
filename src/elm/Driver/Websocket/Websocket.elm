module Driver.Websocket.Websocket exposing (send)

import WebSocket
import Phoenix
import Phoenix.Push as Push
import Driver.Websocket.Messages exposing (Msg(NewReply))
import Requests.Models exposing (RequestID)
import Json.Encode


send : String -> String -> RequestID -> Json.Encode.Value -> Cmd Msg
send channel topic request_id payload =
    let
        message =
            Push.init channel topic
                |> Push.withPayload payload
                |> Push.onOk (\m -> NewReply m request_id)
                |> Push.onError (\m -> NewReply m request_id)
    in
        Phoenix.push "ws://localhost:4000/websocket" message
