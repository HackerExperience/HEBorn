module Driver.Websocket.Subscriptions exposing (subscriptions)

import Time
import Core.Messages exposing (CoreMsg)
import Game.Account.Models exposing (isAuthenticated)
import Phoenix


subscriptions model core =
    let
        socketSub =
            if (isAuthenticated core.game.account && (not model.defer)) then
                Phoenix.connect model.socket model.channels
            else
                Sub.none
    in
        Sub.batch
            [ socketSub ]
