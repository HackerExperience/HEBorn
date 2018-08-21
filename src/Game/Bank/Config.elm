module Game.Bank.Config exposing (..)

import Core.Flags as Core
import Json.Decode exposing (Value)
import Game.Account.Database.Models 
    exposing 
        ( HackedBankAccountID
        , HackedBankAccount
        )
import Game.Account.Finances.Models as Finances 
    exposing 
        ( AccountId
        , BankAccount
        )
import Game.Bank.Messages exposing (Msg)
import Game.Meta.Types.Desktop.Apps exposing (Requester)
import Game.Servers.Shared exposing (..)
import Game.Shared exposing (..)


type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , finances : Finances.Model
    , awaitEvent : String -> ( String, msg ) -> msg
    , accountId : ID
    , activeGatewayCId : Maybe CId
    , activeBounce : Maybe ID
    , onLogin : AccountId -> String -> Value -> msg
    , onLogout : AccountId -> String ->  msg
    , onSendSessionId : String -> Requester -> msg
    , onHackedBankAccountUpdated : 
        HackedBankAccountID 
        -> HackedBankAccount 
        -> msg
    , onBankAccountUpdated : AccountId -> BankAccount -> msg 
    }
