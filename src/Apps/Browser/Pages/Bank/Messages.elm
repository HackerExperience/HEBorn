module Apps.Browser.Pages.Bank.Messages exposing (Msg(..))

import Apps.Browser.Pages.Bank.Models exposing (..)
import Game.Account.Finances.Models exposing (AccountNumber, BankAccountData)
import Game.Meta.Types.Network exposing (NIP)
import Requests.Types exposing (ResponseType)


type Msg
    = HandleLogin BankAccountData
    | HandleLoginError
    | HandleTransfer
    | HandleTransferError
    | UpdateLoginField String
    | UpdatePasswordField String
    | UpdateTransferBankField String
    | UpdateTransferAccountField String
    | UpdateTransferValueField String
