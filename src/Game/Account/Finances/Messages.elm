module Game.Account.Finances.Messages
    exposing
        ( Msg(..)
        , RequestMsg(..)
        , LoginResponse(..)
        , TransferResponse(..)
        )

import Game.Account.Finances.Models exposing (..)
import Requests.Types exposing (ResponseType)
import Game.Web.Models as Web
import Game.Servers.Shared exposing (CId)
import Game.Meta.Types.Network exposing (NIP)
import Game.Meta.Types.Requester exposing (Requester)


type Msg
    = Request RequestMsg
    | HandleBankAccountClosed AccountId
    | HandleBankAccountUpdated AccountId BankAccount
    | HandleBankAccountLogin BankLoginRequest Requester CId
    | HandleBankAccountTransfer BankTransferRequest Requester CId


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
