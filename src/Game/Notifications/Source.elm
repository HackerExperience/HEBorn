module Game.Notifications.Source exposing (..)

import Game.Servers.Shared exposing (CId)


type Source
    = Server CId
    | Account
    | Chat
