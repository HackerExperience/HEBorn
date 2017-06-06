module Game.Servers.Messages exposing (ServerMsg(..))

import Game.Servers.Models exposing (ServerID)
import Game.Servers.Filesystem.Messages exposing (FilesystemMsg)
import Game.Servers.Logs.Messages exposing (LogMsg)
import Game.Servers.Processes.Messages as Processes exposing (Msg)
import Events.Events as Events


type ServerMsg
    = MsgFilesystem ServerID FilesystemMsg
    | MsgLog ServerID LogMsg
    | MsgProcess ServerID Processes.Msg
    | Event Events.Response
