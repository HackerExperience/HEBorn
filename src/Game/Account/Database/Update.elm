module Game.Account.Database.Update exposing (update)

import Utils.React as React exposing (React)
import Events.Account.PasswordAcquired as PasswordAcquired
import Game.Account.Database.Config exposing (..)
import Game.Account.Database.Models exposing (..)
import Game.Account.Database.Messages exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


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
        ( model_, React.none )


onHandleDatabaseAccountRemoved :
    HackedBankAccountID
    -> Model
    -> UpdateResponse msg
onHandleDatabaseAccountRemoved id model =
    let
        model_ =
            { model | bankAccounts = removeBankAccount id model.bankAccounts }
    in
        ( model_, React.none )


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
        ( model_, React.none )
