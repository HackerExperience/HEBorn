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
        HandleBankAccountClosed accountId ->
            handleBankAccountClosed accountId model

        HandleBankAccountUpdated accountId account ->
            handleBankAccountUpdated accountId account model


handleBankAccountClosed : AccountId -> Model -> UpdateResponse
handleBankAccountClosed accountId model =
    Update.fromModel <| removeBankAccount accountId model


handleBankAccountUpdated : AccountId -> BankAccount -> Model -> UpdateResponse
handleBankAccountUpdated accountId bankAccount model =
    Update.fromModel <| insertBankAccount accountId bankAccount model
