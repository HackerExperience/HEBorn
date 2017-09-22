module Driver.Websocket.Subscriptions exposing (subscriptions)

import Dict exposing (Dict)
import Phoenix
import Driver.Websocket.Models exposing (Model)
import Driver.Websocket.Messages exposing (Msg)


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.connect model.socket (Dict.values model.channels)
