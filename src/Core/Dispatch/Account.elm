module Core.Dispatch.Account exposing (..)

import Game.Servers.Shared as Servers
import Game.Meta.Types.Context exposing (Context)
import Game.Inventory.Shared as Inventory
import Game.Account.Finances.Models exposing (AccountId, BankAccount)
import Game.Account.Database.Models
    exposing
        ( HackedBankAccountID
        , HackedBankAccount
        )
import Events.Account.PasswordAcquired as PasswordAcquired


{-| Messages related to player's account.
-}
type Dispatch
    = SetGateway Servers.CId
    | SetEndpoint (Maybe Servers.CId)
    | SetContext Context
    | NewGateway Servers.CId
    | PasswordAcquired PasswordAcquired.Data
    | Finances Finances
    | Database Database
    | LogoutAndCrash ( String, String )
    | Logout
    | Inventory Inventory


type Inventory
    = UsedInventoryEntry Inventory.Entry
    | FreedInventoryEntry Inventory.Entry


type Finances
    = BankAccountClosed AccountId
    | BankAccountUpdated ( AccountId, BankAccount )


type Database
    = DatabaseAccountRemoved HackedBankAccountID
    | DatabaseAccountUpdated ( HackedBankAccountID, HackedBankAccount )
