module Game.Account.Finances.Messages exposing (..)

import Game.Meta.Types.Apps.Desktop exposing (Requester)
import Game.Account.Finances.Requests.Login as LoginRequest
import Game.Account.Finances.Requests.Transfer as TransferRequest
import Game.Account.Finances.Models exposing (..)


type Msg
    = LoginRequest Requester LoginRequest.Data
    | TransferRequest Requester TransferRequest.Data
    | HandleBankAccountClosed AccountId
    | HandleBankAccountUpdated AccountId BankAccount
    | HandleBankAccountLogin LoginRequest.Payload Requester
    | HandleBankAccountTransfer TransferRequest.Payload Requester
