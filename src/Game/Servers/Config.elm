module Game.Servers.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Logs.Config as Logs
import Game.Servers.Processes.Config as Processes
import Game.Servers.Filesystem.Config as Filesystem
import Game.Servers.Tunnels.Config as Tunnels
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


logsConfig : CId -> Config msg -> Logs.Config msg
logsConfig cid config =
    { flags = config.flags
    , toMsg = LogsMsg >> ServerMsg cid >> config.toMsg
    , cid = cid
    }


filesystemConfig : CId -> StorageId -> Config msg -> Filesystem.Config msg
filesystemConfig cid storageId config =
    { flags = config.flags
    , toMsg = FilesystemMsg storageId >> ServerMsg cid >> config.toMsg
    , cid = cid
    }


tunnelsConfig : CId -> Config msg -> Tunnels.Config msg
tunnelsConfig cid config =
    { flags = config.flags
    , toMsg = TunnelsMsg >> ServerMsg cid >> config.toMsg
    }
