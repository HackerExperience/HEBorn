module Game.Servers.Messages exposing (Msg(..), RequestMsg(..))

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
    = SetBounce ID (Maybe Bounces.ID)
    | SetEndpoint ID (Maybe NIP)
    | FilesystemMsg ID Filesystem.Msg
    | LogMsg ID Logs.Msg
    | ProcessMsg ID Processes.Msg
    | TunnelsMsg ID Tunnels.Msg
    | Request RequestMsg
    | Event Events.Event


type RequestMsg
    = LogIndexRequest ResponseType
    | FileIndexRequest ResponseType
