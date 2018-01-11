module Apps.Browser.Pages.Bank.Config exposing (Config)

import Apps.Browser.Pages.Bank.Messages exposing (..)
import Game.Meta.Types.Network as Network
import Game.Account.Finances.Models as Finances


type alias Config msg =
    { toMsg : Msg -> msg
    , onLogin :
        Finances.BankLoginRequest
        -> msg
    , onTransfer :
        Finances.BankTransferRequest
        -> msg
    , onLogout : msg
    }
