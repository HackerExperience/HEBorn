module Game.Account.Database.Messages exposing (Msg(..))

import Events.Account.Handlers.ServerPasswordAcquired as ServerPasswordAcquired
import Events.Account.Handlers.VirusCollected as VirusCollected
import Game.Account.Database.Models
    exposing
        ( HackedBankAccountID
        , HackedBankAccount
        )
import Game.Account.Finances.Models exposing (AtmId, AccountNumber)
import Game.Shared exposing (ID)


type Msg
    = HandlePasswordAcquired ServerPasswordAcquired.Data
    | HandleDatabaseAccountRemoved HackedBankAccountID
    | HandleDatabaseAccountUpdated HackedBankAccountID HackedBankAccount
    | HandleCollectedVirus VirusCollected.Data
