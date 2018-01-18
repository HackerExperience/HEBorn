module Game.Servers.Processes.Config exposing (Config)

import Time exposing (Time)
import Core.Flags as Core
import Game.Servers.Processes.Messages exposing (..)
import Game.Servers.Shared as Servers exposing (CId)
import Game.Meta.Types.Network as Network exposing (NIP)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , cid : CId
    , nip : NIP
    , lastTick : Time
    }
