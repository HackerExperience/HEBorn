module Game.Servers.Messages exposing (Msg(..), RequestMsg(..))

import Game.Servers.Models exposing (ServerID)
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Processes.Messages as Processes
import Events.Events as Events
import Requests.Types exposing (ResponseType)


type Msg
    = FilesystemMsg ServerID Filesystem.Msg
    | LogMsg ServerID Logs.Msg
    | ProcessMsg ServerID Processes.Msg
    | Request RequestMsg
    | Event Events.Response


type RequestMsg
    = LogIndexRequest ResponseType
    | FileIndexRequest ResponseType
