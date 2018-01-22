module Game.Account.Database.Messages exposing (Msg(..))

import Events.Account.Handlers.ServerPasswordAcquired as ServerPasswordAcquired
import Game.Account.Database.Models
    exposing
        ( HackedBankAccountID
        , HackedBankAccount
        )


type Msg
    = HandlePasswordAcquired ServerPasswordAcquired.Data
    | HandleDatabaseAccountRemoved HackedBankAccountID
    | HandleDatabaseAccountUpdated HackedBankAccountID HackedBankAccount
