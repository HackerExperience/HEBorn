module Game.Servers.Messages exposing (ServerMsg(..))

import Game.Servers.Models exposing (ServerID)
import Game.Servers.Filesystem.Messages exposing (FilesystemMsg)
import Game.Servers.Logs.Messages exposing (LogMsg)


type ServerMsg
    = MsgFilesystem ServerID FilesystemMsg
    | MsgLog ServerID LogMsg
