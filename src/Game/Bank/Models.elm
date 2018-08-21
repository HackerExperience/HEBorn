module Game.Bank.Models exposing (..)

import Dict as Dict exposing (Dict)
import Random.Pcg as Random
import Utils.Maybe as Maybe
import Decoders.Bank as Bank
import Game.Account.Finances.Models exposing (AtmId, AccountNumber, AccountId)
import Game.Bank.Shared exposing (BankAccountData)


type alias Model =
    { sessions : BankSessions
    , randomUuidSeed : Random.Seed
    , waiters : Dict String AccountId
    }


type alias BankSessions =
    Dict String BankSession


type alias BankSession =
    { atmId : AtmId
    , accountNumber : AccountNumber
    , accountCache : BankAccountData
    }


initialModel : Model
initialModel =
    Model Dict.empty (Random.initialSeed 8589869056) Dict.empty


getAccountId : String -> Model -> Maybe AccountId
getAccountId id model =
    let
        session =
            getSession id model

        atmId =
            Maybe.map .atmId session

        accountNumber =
            Maybe.map .accountNumber session

        accountId =
            Maybe.uncurry atmId accountNumber
    in
        accountId


getSession : String -> Model -> Maybe BankSession
getSession id =
    .sessions >> Dict.get id


endSession : String -> Model -> Model
endSession id model =
    { model | sessions = Dict.remove id model.sessions }


addWaitingId : String -> AccountId -> Model -> Model
addWaitingId rId id model =
    { model | waiters = Dict.insert rId id model.waiters }


startNewSession :
    String
    -> BankAccountData
    -> Model
    -> Model
startNewSession rId data model =
    let
        waitingId =
            Dict.get rId model.waiters
    in
        case Debug.log "waiting for ID: " waitingId of
            Just ( atmId, accNum ) ->
                insertSession model rId (BankSession atmId accNum data)
            Nothing ->
                model


insertSession : Model -> String -> BankSession -> Model
insertSession model rId session =
    { model | sessions = Dict.insert rId session model.sessions }
