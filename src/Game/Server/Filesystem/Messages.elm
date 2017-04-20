module Game.Server.Filesystem.Messages exposing (FilesystemMsg(..))

import Game.Server.Filesystem.Models exposing (FileID)


type FilesystemMsg
    = DeleteFile FileID
