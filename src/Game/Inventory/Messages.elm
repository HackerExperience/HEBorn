module Game.Inventory.Messages exposing (Msg(..))

import Game.Inventory.Shared exposing (..)


type Msg
    = HandleComponentUsed Entry
    | HandleComponentFreed Entry
