module Game.Account.Finances.Messages exposing (..)

import Game.Meta.Types.Desktop.Apps exposing (Requester)
import Game.Account.Finances.Models exposing (..)


type Msg
    = HandleBankAccountClosed AccountId
    | HandleBankAccountUpdated AccountId BankAccount
