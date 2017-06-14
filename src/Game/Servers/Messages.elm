module Game.Servers.Messages exposing (ServerMsg(..), RequestMsg(..))

import Events.Events as Events
import Game.Servers.Filesystem.Messages exposing (FilesystemMsg)
import Game.Servers.Logs.Messages exposing (LogMsg)
import Game.Servers.Models exposing (ServerID)
import Game.Servers.Processes.Messages exposing (ProcessMsg)
import Requests.Types exposing (ResponseType)


type ServerMsg
    = MsgFilesystem ServerID FilesystemMsg
    | MsgLog ServerID LogMsg
    | MsgProcess ServerID ProcessMsg
    | Request RequestMsg
    | Event Events.Response


type RequestMsg
    = LogIndexRequest ResponseType
    | FileIndexRequest ResponseType
