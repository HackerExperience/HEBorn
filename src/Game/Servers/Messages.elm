module Game.Servers.Messages exposing (ServerMsg(..))

import Game.Servers.Models exposing (ServerID)
import Game.Servers.Filesystem.Messages as Filesystem exposing (Msg)
import Game.Servers.Logs.Messages exposing (LogMsg)
import Game.Servers.Processes.Messages as Processes exposing (Msg)
import Events.Events as Events


type ServerMsg
    = MsgFilesystem ServerID Filesystem.Msg
    | MsgLog ServerID LogMsg
    | MsgProcess ServerID Processes.Msg
    | Event Events.Response
