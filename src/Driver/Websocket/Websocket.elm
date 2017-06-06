module Driver.Websocket.Websocket exposing (send)

import Phoenix
import Phoenix.Push as Push
import Json.Encode exposing (Value)


send :
    (Value -> msg)
    -> String
    -> String
    -> String
    -> Value
    -> Cmd msg
send msg apiHttpUrl channel topic payload =
    let
        message =
            Push.init channel topic
                |> Push.withPayload payload
                |> Push.onOk (msg)
                |> Push.onError (msg)
    in
        Phoenix.push apiHttpUrl message
