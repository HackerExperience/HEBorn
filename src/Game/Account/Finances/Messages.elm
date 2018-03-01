module Game.Account.Finances.Messages
    exposing
        ( Msg(..)
        , RequestMsg(..)
        , LoginResponse(..)
        , TransferResponse(..)
        )

import Requests.Types exposing (ResponseType)
import Game.Meta.Types.Apps.Desktop exposing (Requester)
import Game.Account.Finances.Models exposing (..)
import Game.Account.Finances.Shared exposing (..)


type Msg
    = Request RequestMsg
    | HandleBankAccountClosed AccountId
    | HandleBankAccountUpdated AccountId BankAccount
    | HandleBankAccountLogin BankLoginRequest Requester
    | HandleBankAccountTransfer BankTransferRequest Requester


type RequestMsg
    = BankLogin Requester ResponseType
    | BankTransfer Requester ResponseType


type LoginResponse
    = Valid BankAccountData
    | DecodeFailed
    | Invalid


type TransferResponse
    = Successful
    | Error
