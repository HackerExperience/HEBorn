module Game.Servers.Messages exposing (Msg(..), ItemMsg(..), RequestMsg(..))

import Json.Decode exposing (Value)
import Events.Events as Events
import Requests.Types exposing (ResponseType)
import Game.Account.Bounces.Models as Bounces
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Shared exposing (..)
import Game.Servers.Tunnels.Messages as Tunnels
import Game.Network.Types exposing (NIP)


type Msg
    = Bootstrap Value
    | Item ID ItemMsg
    | Event Events.Event


type ItemMsg
    = SetBounce (Maybe Bounces.ID)
    | SetEndpoint (Maybe NIP)
    | FilesystemMsg Filesystem.Msg
    | LogsMsg Logs.Msg
    | ProcessesMsg Processes.Msg
    | TunnelsMsg Tunnels.Msg
    | ItemEvent Events.Event
    | Request RequestMsg


type RequestMsg
    = ServerRequest ResponseType
