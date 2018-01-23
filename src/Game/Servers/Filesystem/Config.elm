module Game.Servers.Filesystem.Config exposing (Config)

import Core.Flags as Core
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Shared as Servers exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , cid : CId
    }
