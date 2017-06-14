module Game.Servers.Messages exposing (Msg(..), RequestMsg(..))

import Game.Servers.Models exposing (ServerID)
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Processes.Messages as Processes
import Events.Events as Events
import Requests.Types exposing (ResponseType)


type Msg
    = MsgFilesystem ServerID Filesystem.Msg
    | MsgLog ServerID Logs.Msg
    | MsgProcess ServerID Processes.Msg
    | Request RequestMsg
    | Event Events.Response


type RequestMsg
    = LogIndexRequest ResponseType
    | FileIndexRequest ResponseType
