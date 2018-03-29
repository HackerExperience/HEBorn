module Game.Account.Notifications.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Game.Account.Notifications.Shared exposing (..)
import Game.Account.Notifications.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , lastTick : Time
    , onToast : Content -> msg
    }


type alias ActionConfig msg =
    { batchMsg : List msg -> msg
    , openThunderbird : msg
    }
