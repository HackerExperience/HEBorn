module Apps.Browser.Pages.Bank.Messages exposing (Msg(..))

import Apps.Browser.Pages.Bank.Models exposing (Password)
import Game.Account.Finances.Models exposing (AccountNumber)
import Game.Meta.Types.Network exposing (NIP)
import Requests.Types exposing (ResponseType)


type Msg
    = LoginRequest AccountNumber Password
    | TransferRequest NIP AccountNumber NIP AccountNumber Int Password
    | HandleLogin AccountData
    | HandleLoginError
    | HandleTransfer
    | HandleTransferError
    | UpdateLoginField String
    | UpdatePasswordField String
    | UpdateTransferBankField String
    | UpdateTransferAccountField String
    | UpdateTransferValueField String
