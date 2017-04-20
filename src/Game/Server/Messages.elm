module Game.Server.Messages exposing (ServerMsg(..))

import Game.Server.Models exposing (ServerID)
import Game.Server.Filesystem.Messages exposing (FilesystemMsg)


type ServerMsg
    = MsgFilesystem ServerID FilesystemMsg
