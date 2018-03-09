module Game.Account.Finances.Config exposing (Config)

import Core.Flags as Core
import Game.Meta.Types.Apps.Desktop exposing (Requester)
import Game.Account.Models as Account
import Game.Account.Finances.Requests.Login as LoginRequest
import Game.Account.Finances.Requests.Transfer as TransferRequest
import Game.Account.Finances.Messages exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , accountId : Account.ID
    , onBankAccountLogin : LoginRequest.Data -> Requester -> msg
    , onBankAccountTransfer : TransferRequest.Data -> Requester -> msg
    }
