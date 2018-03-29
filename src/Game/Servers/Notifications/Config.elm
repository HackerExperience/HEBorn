module Game.Servers.Notifications.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Game.Servers.Notifications.Shared exposing (..)
import Game.Servers.Notifications.Messages exposing (..)
import Game.Servers.Filesystem.Shared as Filesystem


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , lastTick : Time
    , onToast : Content -> msg
    }


type alias ActionConfig msg =
    { batchMsg : List msg -> msg
    , openTaskManager : msg
    , openExplorerInFile : Filesystem.FileEntry -> msg
    }
