module Apps.Browser.Pages.Bank.Config exposing (Config)

import Apps.Browser.Pages.Bank.Messages exposing (..)
import Game.Meta.Types.Network as Network
import Game.Account.Finances.Models as Finances


type alias Config msg =
    { toMsg : Msg -> msg
    , onLogin :
        Network.NIP
        -> Finances.AccountNumber
        -> String
        -> msg
    , onTransfer :
        Network.NIP
        -> Finances.AccountNumber
        -> Network.NIP
        -> Finances.AccountNumber
        -> String
        -> Int
        -> msg
    , onLogout : msg
    }
