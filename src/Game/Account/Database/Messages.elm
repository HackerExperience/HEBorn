module Game.Account.Database.Messages exposing (Msg(..))

import Events.Account.Handlers.ServerPasswordAcquired as ServerPasswordAcquired
import Events.Account.Handlers.VirusCollected as VirusCollected
import Game.Bank.Shared exposing (BankAccountData)
import Game.Account.Database.Models
    exposing
        ( HackedBankAccountID
        , HackedBankAccount
        , Password
        )


type Msg
    = HandlePasswordAcquired ServerPasswordAcquired.Data
    | HandleDatabaseAccountRemoved HackedBankAccountID
    | HandleDatabaseAccountUpdated HackedBankAccountID HackedBankAccount
    | HandleCollectedVirus VirusCollected.Data
    | HandleDatabaseAccountLoggedIn HackedBankAccountID BankAccountData
    | HandleDatabaseAccountPasswordAcquired HackedBankAccountID String
