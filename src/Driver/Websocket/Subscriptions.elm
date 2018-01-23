module Driver.Websocket.Subscriptions exposing (subscriptions)

import Dict exposing (Dict)
import Phoenix
import Driver.Websocket.Models exposing (..)


subscriptions : Model msg -> Sub msg
subscriptions model =
    model.channels
        |> Dict.values
        |> Phoenix.connect model.socket
