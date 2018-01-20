module Game.Servers.Notifications.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Game.Servers.Notifications.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , lastTick : Time
    }
