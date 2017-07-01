module Game.Servers.Messages exposing (Msg(..), RequestMsg(..))

import Game.Servers.Shared exposing (..)
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Processes.Messages as Processes
import Events.Events as Events
import Requests.Types exposing (ResponseType)


type Msg
    = FilesystemMsg ID Filesystem.Msg
    | LogMsg ID Logs.Msg
    | ProcessMsg ID Processes.Msg
    | Request RequestMsg
    | Event Events.Response


type RequestMsg
    = LogIndexRequest ResponseType
    | FileIndexRequest ResponseType
