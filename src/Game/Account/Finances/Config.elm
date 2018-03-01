module Game.Account.Finances.Config exposing (Config)

import Core.Flags as Core
import Game.Meta.Types.Apps.Desktop exposing (Requester)
import Game.Account.Models as Account
import Game.Account.Finances.Messages exposing (..)
import Game.Account.Finances.Shared exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , accountId : Account.ID
    , onBankAccountLogin : Result () BankAccountData -> Requester -> msg
    , onBankAccountTransfer : Result () () -> Requester -> msg
    }
