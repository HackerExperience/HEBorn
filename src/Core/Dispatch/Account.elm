module Core.Dispatch.Account exposing (..)

import Game.Servers.Shared as Servers
import Game.Meta.Types.Context exposing (Context)
import Game.Servers.Shared exposing (CId)
import Game.Inventory.Shared as Inventory
import Game.Account.Finances.Models exposing (AccountId, BankAccount, AccountNumber)
import Game.Account.Database.Models
    exposing
        ( HackedBankAccountID
        , HackedBankAccount
        )
import Events.Account.PasswordAcquired as PasswordAcquired
import Game.Meta.Types.Network exposing (NIP)
import Game.Meta.Types.Requester exposing (Requester)
import Game.Web.Models as Web


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
    | BankAccountLogin NIP AccountNumber String Requester CId
    | BankAccountTransfer NIP AccountNumber NIP AccountNumber String Int Requester CId


type Database
    = DatabaseAccountRemoved HackedBankAccountID
    | DatabaseAccountUpdated ( HackedBankAccountID, HackedBankAccount )
