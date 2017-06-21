module Driver.Websocket.Subscriptions exposing (subscriptions)

import Phoenix
import Driver.Websocket.Models exposing (Model)
import Driver.Websocket.Messages exposing (Msg)
import Core.Models as Core
import Game.Account.Models exposing (isAuthenticated)


subscriptions : Model -> Core.Model -> Sub Msg
subscriptions model core =
    if (isAuthenticated core.game.account && not model.defer) then
        Phoenix.connect model.socket model.channels
    else
        Sub.none
