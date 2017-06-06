module Game.Servers.Filesystem.Messages exposing (Msg(..))

import Game.Servers.Filesystem.Models exposing (FileID)


type Msg
    = Delete FileID
