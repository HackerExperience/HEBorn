module Game.Servers.Messages
    exposing
        ( Msg(..)
        , ServerMsg(..)
        , RequestMsg(..)
        , ServerRequestMsg(..)
        )

import Json.Decode exposing (Value)
import Events.Events as Events
import Requests.Types exposing (ResponseType)
import Game.Account.Bounces.Models as Bounces
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Shared exposing (..)
import Game.Servers.Tunnels.Messages as Tunnels
import Game.Notifications.Messages as Notifications
import Game.Network.Types as Network


-- messages and requests received by the server collection


type Msg
    = ServerMsg ID ServerMsg
    | Request RequestMsg
    | Event Events.Event


type RequestMsg
    = BootstrapRequest ResponseType



-- messages and requests received by a single server


type ServerMsg
    = SetBounce (Maybe Bounces.ID)
    | SetEndpoint (Maybe Network.NIP)
    | FilesystemMsg Filesystem.Msg
    | LogsMsg Logs.Msg
    | ProcessesMsg Processes.Msg
    | TunnelsMsg Tunnels.Msg
    | ServerEvent Events.Event
    | ServerRequest ServerRequestMsg
    | NotificationsMsg Notifications.Msg


type ServerRequestMsg
    = NoOp
