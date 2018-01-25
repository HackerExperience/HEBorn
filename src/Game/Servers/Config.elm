module Game.Servers.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Game.Inventory.Shared as Inventory
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Notifications.Shared as Notifications
import Game.Servers.Notifications.Messages as Notifications
import Game.Servers.Notifications.Config as Notifications
import Game.Servers.Processes.Config as Processes
import Game.Servers.Logs.Config as Logs
import Game.Servers.Filesystem.Config as Filesystem
import Game.Servers.Tunnels.Config as Tunnels
import Game.Servers.Hardware.Config as Hardware
import Game.Servers.Messages exposing (..)
import Game.Servers.Shared exposing (..)
import Game.Servers.Models exposing (Server)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , lastTick : Time
    , activeCId : Maybe CId
    , activeGateway : Maybe ( CId, Server )
    , onSetGatewayContext : msg
    , onInventoryFreed : Inventory.Entry -> msg
    , onInventoryUsed : Inventory.Entry -> msg
    , onNewGateway : CId -> msg

    -- account.notifications
    , onToast : CId -> Notifications.Content -> msg
    }


processesConfig : CId -> NIP -> Config msg -> Processes.Config msg
processesConfig cid nip config =
    { flags = config.flags
    , toMsg = ProcessesMsg >> ServerMsg cid >> config.toMsg
    , batchMsg = config.batchMsg
    , cid = cid
    , nip = nip
    , lastTick = config.lastTick
    , onDownloadStarted =
        \storage ->
            Notifications.HandleDownloadStarted nip storage
                >> NotificationsMsg
                >> ServerMsg cid
                >> config.toMsg
    , onDownloadFailed =
        \title ->
            Notifications.HandleGeneric title
                >> NotificationsMsg
                >> ServerMsg cid
                >> config.toMsg
    }


logsConfig : CId -> Config msg -> Logs.Config msg
logsConfig cid config =
    { flags = config.flags
    , toMsg = LogsMsg >> ServerMsg cid >> config.toMsg
    , batchMsg = config.batchMsg
    , cid = cid
    }


filesystemConfig : CId -> StorageId -> Config msg -> Filesystem.Config msg
filesystemConfig cid storageId config =
    { flags = config.flags
    , toMsg = FilesystemMsg storageId >> ServerMsg cid >> config.toMsg
    , batchMsg = config.batchMsg
    , cid = cid
    }


tunnelsConfig : CId -> Config msg -> Tunnels.Config msg
tunnelsConfig cid config =
    { flags = config.flags
    , toMsg = TunnelsMsg >> ServerMsg cid >> config.toMsg
    , cid = cid
    }


hardwareConfig : CId -> NIP -> Config msg -> Hardware.Config msg
hardwareConfig cid nip config =
    { flags = config.flags
    , toMsg = HardwareMsg >> ServerMsg cid >> config.toMsg
    , batchMsg = config.batchMsg
    , cid = cid
    , onInventoryFreed = config.onInventoryFreed
    , onInventoryUsed = config.onInventoryUsed
    }


notificationsConfig : CId -> Config msg -> Notifications.Config msg
notificationsConfig cid config =
    { flags = config.flags
    , toMsg = NotificationsMsg >> ServerMsg cid >> config.toMsg
    , lastTick = config.lastTick
    , onToast = config.onToast cid
    }
