module Driver.Websocket.Websocket exposing (send)

import Json.Encode
import Phoenix
import Phoenix.Push as Push
import Driver.Websocket.Messages exposing (Msg(NewReply))
import Requests.Models exposing (RequestID)
import Core.Messages exposing (CoreMsg(MsgWebsocket))


send : String -> String -> RequestID -> Json.Encode.Value -> Cmd CoreMsg
send channel topic request_id payload =
    let
        message =
            Push.init channel topic
                |> Push.withPayload payload
                |> Push.onOk (\m -> NewReply m request_id)
                |> Push.onError (\m -> NewReply m request_id)
    in
        Cmd.map
            MsgWebsocket
            (Phoenix.push "ws://localhost:4000/websocket" message)
