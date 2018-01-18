module Game.Servers.Hardware.Config exposing (..)

import Core.Flags as Core
import Game.Servers.Hardware.Messages exposing (..)
import Game.Servers.Shared as Servers exposing (CId)
import Game.Meta.Types.Network as Network exposing (NIP)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , cid : CId
    }
