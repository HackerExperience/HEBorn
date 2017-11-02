module Game.Notifications.Source exposing (..)

import Game.Notifications.Models as Notifications
import Game.Servers.Shared exposing (CId)


type Source
    = Server CId
    | Account
    | Chat
