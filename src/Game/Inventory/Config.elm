module Game.Inventory.Config exposing (..)

import Core.Flags as Core
import Game.Inventory.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , flags : Core.Flags
    }
