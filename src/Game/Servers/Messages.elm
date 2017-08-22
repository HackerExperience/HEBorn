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
import Game.Servers.Web.Messages as Web
import Game.Network.Types exposing (NIP)


type Msg
    = Bootstrap Value
    | ServerMsg ID ServerMsg
    | Request RequestMsg
    | Event Events.Event


type ServerMsg
    = SetBounce (Maybe Bounces.ID)
    | SetEndpoint (Maybe NIP)
    | FilesystemMsg Filesystem.Msg
    | LogsMsg Logs.Msg
    | ProcessesMsg Processes.Msg
    | TunnelsMsg Tunnels.Msg
    | WebMsg Web.Msg
    | ServerEvent Events.Event
    | ServerRequest ServerRequestMsg


type RequestMsg
    = FetchRequest ResponseType


type ServerRequestMsg
    = NoOp
