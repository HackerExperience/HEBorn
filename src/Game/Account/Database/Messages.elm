module Game.Account.Database.Messages exposing (Msg(..))

import Events.Account.PasswordAcquired as PasswordAcquired
import Game.Account.Database.Models
    exposing
        ( HackedBankAccountID
        , HackedBankAccount
        )


type Msg
    = HandlePasswordAcquired PasswordAcquired.Data
    | HandleDatabaseAccountRemoved HackedBankAccountID
    | HandleDatabaseAccountUpdated HackedBankAccountID HackedBankAccount
