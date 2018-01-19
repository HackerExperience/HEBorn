module Game.Servers.Processes.Config exposing (Config)

import Time exposing (Time)
import Core.Flags as Core
import Game.Notifications.Models as Notifications
import Game.Servers.Shared as Servers exposing (CId)
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Processes.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , cid : CId
    , nip : NIP
    , lastTick : Time
    , notifyServer : Notifications.Content -> msg
    }
