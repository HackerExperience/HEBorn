module Game.Account.Finances.Messages exposing (Msg(..))

import Game.Account.Finances.Models
    exposing
        ( AccountId
        , AccountNumber
        , BankAccount
        , Model
        )
import Game.Data as Game
import Requests.Types exposing (ResponseType)
import Apps.Reference exposing (Reference)
import Game.Meta.Types.Network exposing (NIP)


type Msg
    = Request RequestMsg
    | HandleBankAccountClosed AccountId
    | HandleBankAccountUpdated AccountId BankAccount
    | HandleBankLogin Game.Data NIP AccountNumber String Reference
    | HandleBankTransfer Game.Data NIP AccountNumber NIP AccountNumber String Int Reference


type RequestMsg
    = BankLogin Reference ResponseType
    | BankTransfer Reference ResponseType
