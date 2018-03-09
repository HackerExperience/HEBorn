module Apps.Browser.Pages.Bank.Config exposing (Config)

import Game.Account.Finances.Requests.Login as LoginRequest
import Game.Account.Finances.Requests.Transfer as TransferRequest
import Apps.Browser.Pages.Bank.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , onLogin : LoginRequest.Payload -> msg
    , onTransfer : TransferRequest.Payload -> msg
    , onLogout : msg
    }
