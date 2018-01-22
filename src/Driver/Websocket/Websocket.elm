module Driver.Websocket.Websocket exposing (send)

import Phoenix
import Phoenix.Push as Push
import Json.Decode exposing (Value)


send :
    (Value -> msg)
    -> (Value -> msg)
    -> String
    -> String
    -> String
    -> Value
    -> Cmd msg
send okMsg errorMsg apiHttpUrl channel topic payload =
    let
        message =
            Push.init channel topic
                |> Push.onError (errorMsg)
                |> Push.onOk (okMsg)
                |> Push.withPayload payload
    in
        Phoenix.push apiHttpUrl message
