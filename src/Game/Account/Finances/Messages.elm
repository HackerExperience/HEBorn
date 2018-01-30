module Game.Account.Finances.Messages
    exposing
        ( Msg(..)
        , RequestMsg(..)
        , LoginResponse(..)
        , TransferResponse(..)
        )

import Requests.Types exposing (ResponseType)
import Game.Servers.Shared exposing (CId)
import Game.Meta.Types.Apps.Desktop exposing (Requester)
import Game.Account.Finances.Models exposing (..)
import Game.Account.Finances.Shared exposing (..)


type Msg
    = Request RequestMsg
    | HandleBankAccountClosed AccountId
    | HandleBankAccountUpdated AccountId BankAccount
    | HandleBankAccountLogin CId BankLoginRequest Requester
    | HandleBankAccountTransfer CId BankTransferRequest Requester


type RequestMsg
    = BankLogin Requester CId ResponseType
    | BankTransfer Requester CId ResponseType


type LoginResponse
    = Valid BankAccountData
    | DecodeFailed
    | Invalid


type TransferResponse
    = Successful
    | Error
