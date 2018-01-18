module Game.Servers.Logs.Config exposing (Config)

import Time exposing (Time)
import Core.Flags as Core
import Game.Servers.Logs.Messages exposing (..)
import Game.Servers.Shared as Servers exposing (CId)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , cid : CId
    }
