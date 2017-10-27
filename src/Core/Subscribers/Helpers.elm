module Core.Subscribers.Helpers exposing (..)

import Core.Messages as Core
import Driver.Websocket.Messages as Ws
import Setup.Messages as Setup
import Game.Messages as Game
import Game.Account.Messages as Account
import Game.Servers.Messages as Servers


type alias Subscribers =
    List Core.Msg


ws : Ws.Msg -> Core.Msg
ws =
    Core.WebsocketMsg


setup : Setup.Msg -> Core.Msg
setup =
    Core.SetupMsg


game : Game.Msg -> Core.Msg
game =
    Core.GameMsg


account : Account.Msg -> Core.Msg
account =
    Game.AccountMsg >> game


servers : Servers.Msg -> Core.Msg
servers =
    Game.ServersMsg >> game
