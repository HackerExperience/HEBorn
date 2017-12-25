module Game.Account.Database.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Events.Account.PasswordAcquired as PasswordAcquired
import Game.Account.Database.Models exposing (..)
import Game.Account.Database.Messages exposing (..)
import Game.Models as Game


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        HandlePasswordAcquired data ->
            handlePasswordAcquired data model

        HandleDatabaseAccountAcquired id account ->
            onHandleDatabaseAccountAcquired id account model

        HandleDatabaseAccountRemoved id ->
            onHandleDatabaseAccountRemoved id model

        HandleDatabaseAccountUpdated id account ->
            onHandleDatabaseAccountUpdated id account model


{-| Saves password for that server, inserts a new server entry
if none is found.
-}
handlePasswordAcquired : PasswordAcquired.Data -> Model -> UpdateResponse
handlePasswordAcquired data model =
    let
        servers =
            getHackedServers model

        model_ =
            servers
                |> getHackedServer data.nip
                |> setPassword data.password
                |> flip (insertServer data.nip) servers
                |> flip setHackedServers model
    in
        Update.fromModel model_


onHandleDatabaseAccountAcquired :
    HackedBankAccountID
    -> HackedBankAccount
    -> Model
    -> UpdateResponse
onHandleDatabaseAccountAcquired id account model =
    let
        bankAccounts =
            insertBankAccount id account model.bankAccounts

        model_ =
            { model | bankAccounts = bankAccounts }
    in
        Update.fromModel model_


onHandleDatabaseAccountRemoved :
    HackedBankAccountID
    -> Model
    -> UpdateResponse
onHandleDatabaseAccountRemoved id model =
    let
        bankAccounts =
            removeBankAccount id model.bankAccounts

        model_ =
            { model | bankAccounts = bankAccounts }
    in
        Update.fromModel model_


onHandleDatabaseAccountUpdated :
    HackedBankAccountID
    -> HackedBankAccount
    -> Model
    -> UpdateResponse
onHandleDatabaseAccountUpdated id account model =
    let
        bankAccounts =
            insertBankAccount id account model.bankAccounts

        model_ =
            { model | bankAccounts = bankAccounts }
    in
        Update.fromModel model_
