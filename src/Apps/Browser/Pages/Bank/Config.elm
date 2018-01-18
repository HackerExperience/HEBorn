module Apps.Browser.Pages.Bank.Config exposing (Config)

import Apps.Browser.Pages.Bank.Messages exposing (..)
import Game.Meta.Types.Network as Network
import Game.Account.Finances.Models exposing (BankLoginRequest, BankTransferRequest)


type alias Config msg =
    { toMsg : Msg -> msg
    , onLogin : BankLoginRequest -> msg
    , onTransfer : BankTransferRequest -> msg
    , onLogout : msg
    }
