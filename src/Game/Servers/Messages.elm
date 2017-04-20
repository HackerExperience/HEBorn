module Game.Servers.Messages exposing (ServerMsg(..))

import Game.Servers.Models exposing (ServerID)
import Game.Servers.Filesystem.Messages exposing (FilesystemMsg)


type ServerMsg
    = MsgFilesystem ServerID FilesystemMsg
