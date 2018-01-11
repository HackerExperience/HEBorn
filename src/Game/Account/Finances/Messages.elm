module Game.Account.Finances.Messages
    exposing
        ( Msg(..)
        , RequestMsg(..)
        , LoginResponse(..)
        , TransferResponse(..)
        )

import Game.Account.Finances.Models
    exposing
        ( AccountId
        , AccountNumber
        , BankAccount
        , BankAccountData
        , Model
        )
import Requests.Types exposing (ResponseType)
import Game.Web.Models as Web
import Game.Servers.Shared exposing (CId)
import Game.Meta.Types.Network exposing (NIP)


type Msg
    = Request RequestMsg
    | HandleBankAccountClosed AccountId
    | HandleBankAccountUpdated AccountId BankAccount
    | HandleBankAccountLogin NIP AccountNumber String Web.Requester CId
    | HandleBankAccountTransfer NIP AccountNumber NIP AccountNumber String Int Web.Requester CId


type RequestMsg
    = BankLogin Web.Requester CId ResponseType
    | BankTransfer Web.Requester CId ResponseType


type LoginResponse
    = Valid BankAccountData
    | DecodeFailed
    | Invalid


type TransferResponse
    = Successful
    | Error
