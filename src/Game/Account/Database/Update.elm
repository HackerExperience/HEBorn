module Game.Account.Database.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Account.PasswordAcquired as PasswordAcquired
import Game.Account.Database.Config exposing (..)
import Game.Account.Database.Models exposing (..)
import Game.Account.Database.Messages exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandlePasswordAcquired data ->
            handlePasswordAcquired data model

        HandleDatabaseAccountRemoved id ->
            onHandleDatabaseAccountRemoved id model

        HandleDatabaseAccountUpdated id account ->
            onHandleDatabaseAccountUpdated id account model


{-| Saves password for that server, inserts a new server entry
if none is found.
-}
handlePasswordAcquired : PasswordAcquired.Data -> Model -> UpdateResponse msg
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


onHandleDatabaseAccountRemoved :
    HackedBankAccountID
    -> Model
    -> UpdateResponse msg
onHandleDatabaseAccountRemoved id model =
    let
        model_ =
            { model | bankAccounts = removeBankAccount id model.bankAccounts }
    in
        Update.fromModel model_


onHandleDatabaseAccountUpdated :
    HackedBankAccountID
    -> HackedBankAccount
    -> Model
    -> UpdateResponse msg
onHandleDatabaseAccountUpdated id account model =
    let
        model_ =
            { model
                | bankAccounts = insertBankAccount id account model.bankAccounts
            }
    in
        Update.fromModel model_
