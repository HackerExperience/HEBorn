module Game.Servers.Hardware.Config exposing (..)

import Core.Flags as Core
import Game.Inventory.Shared as Inventory
import Game.Servers.Shared as Servers exposing (CId)
import Game.Servers.Hardware.Messages exposing (..)


{-| Config do Hardware, contém duas mensagens configuraveis:

  - onInventoryFreed

É lançada quando um item do inventório for liberado:

  - onInventoryUsed

É lançada quando um item do inventório for utilizado.

-}
type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , cid : CId
    , onInventoryFreed : Inventory.Entry -> msg
    , onInventoryUsed : Inventory.Entry -> msg
    }
