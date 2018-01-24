module Game.Servers.Messages exposing (Msg(..), ServerMsg(..))

import Json.Decode exposing (Value)
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Network as Network
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Hardware.Messages as Hardware
import Game.Servers.Tunnels.Messages as Tunnels
import Game.Servers.Notifications.Messages as Notifications
import Game.Servers.Shared exposing (..)
import Game.Servers.Models exposing (..)


-- messages and requests received by the server collection


type Msg
    = ServerMsg CId ServerMsg
    | Synced CId Server
    | HandleResync CId
    | HandleJoinedServer CId Value
    | HandleDisconnect CId



-- messages and requests received by a single server


type ServerMsg
    = HandleLogout
    | HandleSetBounce (Maybe Bounces.ID)
    | HandleSetEndpoint (Maybe CId)
    | HandleSetActiveNIP Network.NIP
    | FilesystemMsg StorageId Filesystem.Msg
    | LogsMsg Logs.Msg
    | ProcessesMsg Processes.Msg
    | HardwareMsg Hardware.Msg
    | TunnelsMsg Tunnels.Msg
    | NotificationsMsg Notifications.Msg
