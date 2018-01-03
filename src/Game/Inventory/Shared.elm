module Game.Inventory.Shared exposing (..)

import Dict exposing (Dict)
import Game.Meta.Types.Components as Components exposing (Components)
import Game.Meta.Types.Network.Connections as Connections exposing (Connections)


type Entry
    = Component Components.Id
    | NetConnection Connections.Id


type alias Groups =
    Dict String Group


{-| Left is for available entries, right for unavailable.
-}
type alias Group =
    ( Entries, Entries )


type alias Entries =
    List Entry
