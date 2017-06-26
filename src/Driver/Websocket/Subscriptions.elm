module Driver.Websocket.Subscriptions exposing (subscriptions)

import Phoenix
import Driver.Websocket.Models exposing (Model)
import Driver.Websocket.Messages exposing (Msg)


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.connect model.socket model.channels
