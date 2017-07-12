module Game.Servers.Filesystem.Messages exposing (Msg(..))

import Game.Servers.Filesystem.Models exposing (FileID, FilePath)


type Msg
    = Delete FileID
    | CreateTextFile FilePath String
    | CreateEmptyDir FilePath String
    | Move FileID FilePath
    | Rename FileID String
