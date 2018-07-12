module Apps.Browser.Pages.Bank.Config exposing (Config)

import Game.Account.Finances.Models exposing (AccountId, AccountNumber)
import Game.Bank.Models as Bank
import Game.Meta.Types.Network exposing (IP)
import Apps.Browser.Pages.Bank.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , bank : Bank.Model
    , onLogin : AccountId -> String -> msg
    , onLoginToken : AccountId -> String -> msg
    , onChangePassword : String -> msg
    , onTransfer : String -> IP -> AccountNumber -> Int -> msg
    , onLogout : String -> msg
    }
