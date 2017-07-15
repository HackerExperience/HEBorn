module Game.Servers.Filesystem.Messages exposing (Msg(..))

import Game.Servers.Filesystem.Shared exposing (FileID, FilePath, Location)


type Msg
    = Delete FileID
    | CreateTextFile FilePath
    | CreateEmptyDir FilePath
    | Move FileID Location
    | Rename FileID String
