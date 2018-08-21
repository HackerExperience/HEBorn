module Events.Bank.Handler exposing (events)

import Events.Shared exposing (Router)
import Events.Bank.Config exposing (..)
import Events.Bank.Handlers.Login as BankLogin
import Game.Account.Finances.Models as Finances


events : Config msg -> String -> Finances.AccountId -> Router msg
events config requestId ( atmId, accNum ) name value =
    case name of
        "bank_login" ->
            BankLogin.handler config.onBankLogin value
        {-
           "bank_account_updated" ->
               config.fakeHandler (config.batchMsg []) value
           "bank_account_removed" ->
               config.fakeHandler (config.batchMsg []) value
           "bank_login" ->
               config.fakeHandler (config.batchMsg []) value
           "bank_logout" ->
               config.fakeHandler (config.batchMsg []) value
           "bank_transfer_successful" ->
               config.fakeHandler (config.batchMsg []) value
           "bank_transfer_failed" ->
               config.fakeHandler (config.batchMsg []) value
           "bank_password_revealed" ->
               config.fakeHandler (config.batchMsg []) value
        -}
        _ ->
            Err "This channel is not implemented yet."
