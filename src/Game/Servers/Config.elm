module Game.Servers.Config exposing (Config, processesConfig)

import Time exposing (Time)
import Core.Flags as Core
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Processes.Config as Processes
import Game.Servers.Messages exposing (..)
import Game.Servers.Shared exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , lastTick : Time
    }


processesConfig : CId -> NIP -> Config msg -> Processes.Config msg
processesConfig cid nip config =
    { flags = config.flags
    , toMsg = ProcessesMsg >> ServerMsg cid >> config.toMsg
    , cid = cid
    , nip = nip
    , lastTick = config.lastTick
    }
