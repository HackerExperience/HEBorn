module Game.Servers.Tunnels.Config exposing (Config)

import Core.Flags as Core
import Game.Servers.Tunnels.Messages exposing (..)
import Game.Servers.Shared as Servers exposing (CId)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , cid : CId
    }
