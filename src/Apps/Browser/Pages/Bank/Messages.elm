module Apps.Browser.Pages.Bank.Messages exposing (Msg(..))

import Game.Account.Finances.Shared exposing (BankAccountData)


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
