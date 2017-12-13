module Game.Servers.Messages
    exposing
        ( Msg(..)
        , ServerMsg(..)
        , RequestMsg(..)
        , ServerRequestMsg(..)
        )

import Json.Decode exposing (Value)
import Requests.Types exposing (ResponseType)
import Game.Account.Bounces.Models as Bounces
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Hardware.Messages as Hardware
import Game.Servers.Shared exposing (..)
import Game.Servers.Models exposing (..)
import Game.Servers.Tunnels.Messages as Tunnels
import Game.Notifications.Messages as Notifications


-- messages and requests received by the server collection


type Msg
    = ServerMsg CId ServerMsg
    | Resync CId
    | Request RequestMsg
    | HandleJoinedServer CId Value


type RequestMsg
    = ResyncRequest (Maybe GatewayCache) CId ResponseType



-- messages and requests received by a single server


type ServerMsg
    = HandleSetBounce (Maybe Bounces.ID)
    | HandleSetEndpoint (Maybe CId)
    | FilesystemMsg StorageId Filesystem.Msg
    | LogsMsg Logs.Msg
    | ProcessesMsg Processes.Msg
    | HardwareMsg Hardware.Msg
    | TunnelsMsg Tunnels.Msg
    | ServerRequest ServerRequestMsg
    | NotificationsMsg Notifications.Msg


type ServerRequestMsg
    = NoOp
