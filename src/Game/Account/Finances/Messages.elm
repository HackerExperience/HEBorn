module Game.Account.Finances.Messages exposing (Msg(..))

import Game.Account.Finances.Models
    exposing
        ( AccountId
        , BankAccount
        , Model
        )


type Msg
    = HandleBankAccountClosed AccountId
    | HandleBankAccountUpdated AccountId BankAccount
