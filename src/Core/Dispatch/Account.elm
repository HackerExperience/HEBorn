module Core.Dispatch.Account exposing (..)

import Game.Servers.Shared as Servers
import Game.Meta.Types.Context exposing (Context)
import Game.Inventory.Shared as Inventory
import Events.Account.PasswordAcquired as PasswordAcquired


{-| Messages related to player's account.
-}
type Dispatch
    = SetGateway Servers.CId
    | SetEndpoint (Maybe Servers.CId)
    | SetContext Context
    | NewGateway Servers.CId
    | PasswordAcquired PasswordAcquired.Data
    | LogoutAndCrash ( String, String )
    | Logout
    | Inventory Inventory


type Inventory
    = UsedInventoryEntry Inventory.Entry
    | FreedInventoryEntry Inventory.Entry
