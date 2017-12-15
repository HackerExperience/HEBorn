module Game.Account.Finances.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Models as Game
import Game.Account.Finances.Messages exposing (..)
import Game.Account.Finances.Models exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        HandleBankAccountOpened accountId account ->
            handleBankAccountOpened accountId account model

        HandleBankAccountClosed accountId ->
            handleBankAccountClosed accountId model

        HandleBankAccountUpdated accountId account ->
            handleBankAccountUpdated accountId account model


handleBankAccountOpened : AccountId -> BankAccount -> Model -> UpdateResponse
handleBankAccountOpened accountId bankAccount model =
    model
        |> insertBankAccount accountId bankAccount
        |> Update.fromModel


handleBankAccountClosed : AccountId -> Model -> UpdateResponse
handleBankAccountClosed accountId model =
    model
        |> removeBankAccount accountId
        |> Update.fromModel


handleBankAccountUpdated : AccountId -> BankAccount -> Model -> UpdateResponse
handleBankAccountUpdated accountId bankAccount model =
    model
        |> insertBankAccount accountId bankAccount
        |> Update.fromModel
