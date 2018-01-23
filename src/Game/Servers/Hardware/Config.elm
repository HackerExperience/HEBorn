module Game.Servers.Hardware.Config exposing (..)

import Core.Flags as Core
import Game.Inventory.Shared as Inventory
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Shared as Servers exposing (CId)
import Game.Servers.Hardware.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , cid : CId
    , onInventoryFreed : Inventory.Entry -> msg
    , onInventoryUsed : Inventory.Entry -> msg
    }
