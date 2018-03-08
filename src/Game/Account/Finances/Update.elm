module Game.Account.Finances.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Meta.Types.Apps.Desktop exposing (Requester)
import Game.Account.Finances.Requests.Login as LoginRequest exposing (loginRequest)
import Game.Account.Finances.Requests.Transfer as TransferRequest exposing (transferRequest)
import Game.Account.Finances.Config exposing (..)
import Game.Account.Finances.Models exposing (..)
import Game.Account.Finances.Messages exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleBankAccountClosed accountId ->
            handleBankAccountClosed accountId model

        HandleBankAccountUpdated accountId account ->
            handleBankAccountUpdated accountId account model

        HandleBankAccountLogin payload requester ->
            handleBankAccountLogin config payload requester model

        HandleBankAccountTransfer payload requester ->
            handleBankAccountTransfer config payload requester model

        LoginRequest requester data ->
            onLoginRequest config requester data model

        TransferRequest requester data ->
            onTransferRequest config requester data model


handleBankAccountClosed : AccountId -> Model -> UpdateResponse msg
handleBankAccountClosed accountId model =
    ( removeBankAccount accountId model, React.none )


handleBankAccountUpdated : AccountId -> BankAccount -> Model -> UpdateResponse msg
handleBankAccountUpdated accountId bankAccount model =
    ( insertBankAccount accountId bankAccount model, React.none )


handleBankAccountLogin :
    Config msg
    -> LoginRequest.Payload
    -> Requester
    -> Model
    -> UpdateResponse msg
handleBankAccountLogin config payload requester model =
    let
        request_ =
            config
                |> loginRequest payload config.accountId
                |> Cmd.map (LoginRequest requester >> config.toMsg)
                |> React.cmd
    in
        ( model, request_ )


handleBankAccountTransfer :
    Config msg
    -> TransferRequest.Payload
    -> Requester
    -> Model
    -> UpdateResponse msg
handleBankAccountTransfer config payload requester model =
    let
        request_ =
            config
                |> transferRequest payload config.accountId
                |> Cmd.map (TransferRequest requester >> config.toMsg)
                |> React.cmd
    in
        ( model, request_ )


onLoginRequest :
    Config msg
    -> Requester
    -> LoginRequest.Data
    -> Model
    -> UpdateResponse msg
onLoginRequest config requester data model =
    ( model, React.msg <| config.onBankAccountLogin data requester )


onTransferRequest :
    Config msg
    -> Requester
    -> TransferRequest.Data
    -> Model
    -> UpdateResponse msg
onTransferRequest config requester data model =
    ( model, React.msg <| config.onBankAccountTransfer data requester )
