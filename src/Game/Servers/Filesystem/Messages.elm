module Game.Servers.Filesystem.Messages exposing (FilesystemMsg(..))

import Game.Servers.Filesystem.Models exposing (FileID)


type FilesystemMsg
    = DeleteFile FileID
