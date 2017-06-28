module Game.Servers.Messages exposing (Msg(..), RequestMsg(..))

import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Processes.Messages as Processes
import Events.Events as Events
import Requests.Types exposing (ResponseType)


type Msg
    = FilesystemMsg Servers.ID Filesystem.Msg
    | LogMsg Servers.ID Logs.Msg
    | ProcessMsg Servers.ID Processes.Msg
    | Request RequestMsg
    | Event Events.Response


type RequestMsg
    = LogIndexRequest ResponseType
    | FileIndexRequest ResponseType
