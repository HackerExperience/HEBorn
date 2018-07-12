module Game.Bank.Messages exposing (Msg(..))

import Json.Decode exposing (Value)
import Game.Account.Finances.Models exposing (AccountId, AtmId, AccountNumber)
import Game.Bank.Shared exposing (BankAccountData)
import Game.Meta.Types.Desktop.Apps exposing (Requester)
import Game.Meta.Types.Network exposing (IP)


type
    Msg
    -- TODO: push BounceId, ServerId, AccountId on config
    = HandleLogin AccountId String Requester
    | HandleLoginToken AccountId String Requester
    | HandleJoinedBank String Value
    | HandleCreateAccount AtmId Requester
      -- the first String Parameter is for SessionId
    | HandleCloseAccount String Requester
    | HandleChangePassword String Requester
    | HandleTransfer String IP AccountNumber Int Requester
    | HandleRevealPassword String String Requester
    | HandleResync String Requester
    | HandleLogout String Requester
    | HandleLoggedIn AccountId Int String
    | UpdateCache String BankAccountData
