module Apps.Browser.Pages.Bank.Update exposing (update)

import Utils.React as React exposing (React)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Account.Finances.Requests.Login as LoginRequest
import Game.Account.Finances.Requests.Transfer as TransferRequest
import Apps.Browser.Config as BrowserConfig
import Apps.Browser.Pages.Bank.Config exposing (..)
import Apps.Browser.Pages.Bank.Models exposing (..)
import Apps.Browser.Pages.Bank.Messages exposing (..)
import Game.Account.Finances.Models exposing (AccountNumber)
import Game.Account.Finances.Shared exposing (BankAccountData)
import Requests.Types exposing (ResponseType)


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        HandleLogin accData ->
            handleLogin config accData model

        HandleLoginError ->
            handleLoginError config model

        HandleTransfer ->
            handleTransfer config model

        HandleTransferError ->
            handleTransferError config model

        UpdateLoginField str ->
            onUpdateLoginField config str model

        UpdatePasswordField str ->
            onUpdatePasswordField config str model

        UpdateTransferBankField str ->
            onUpdateTransferBankField config str model

        UpdateTransferAccountField str ->
            onUpdateTransferAccountField config str model

        UpdateTransferValueField str ->
            onUpdateTransferValueField config str model


onUpdateLoginField :
    Config msg
    -> String
    -> Model
    -> UpdateResponse msg
onUpdateLoginField config str model =
    if (String.contains "-" str) then
        ( model, React.none )
    else
        case (String.toInt str) of
            Result.Ok num ->
                ( { model | accountNum = Just num }, React.none )

            Result.Err _ ->
                ( model, React.none )


onUpdatePasswordField :
    Config msg
    -> String
    -> Model
    -> UpdateResponse msg
onUpdatePasswordField config str model =
    ( { model | password = Just str }, React.none )


onUpdateTransferBankField :
    Config msg
    -> String
    -> Model
    -> UpdateResponse msg
onUpdateTransferBankField config str model =
    if (String.contains "-" str) then
        ( model, React.none )
    else
        ( { model | toBankTransfer = Just (Network.fromString str) }, React.none )


onUpdateTransferAccountField :
    Config msg
    -> String
    -> Model
    -> UpdateResponse msg
onUpdateTransferAccountField config str model =
    if (String.contains "-" str) then
        ( model, React.none )
    else
        case (String.toInt str) of
            Result.Ok num ->
                ( { model | toAccountTransfer = Just num }, React.none )

            Result.Err _ ->
                ( model, React.none )


onUpdateTransferValueField :
    Config msg
    -> String
    -> Model
    -> UpdateResponse msg
onUpdateTransferValueField config str model =
    if (String.contains "-" str) then
        ( model, React.none )
    else
        case (String.toInt str) of
            Result.Ok num ->
                ( { model | transferValue = Just num }, React.none )

            Result.Err _ ->
                ( model, React.none )


handleLogin :
    Config msg
    -> BankAccountData
    -> Model
    -> UpdateResponse msg
handleLogin config accData model =
    let
        model_ =
            { model
                | loggedIn = True
                , bankState = Main
                , accountData = Just accData
                , error = Nothing
            }
    in
        ( model_, React.none )


handleLoginError :
    Config msg
    -> Model
    -> UpdateResponse msg
handleLoginError config model =
    let
        model_ =
            { model | error = Just "Invalid Login Information" }
    in
        ( model_, React.none )


handleTransfer :
    Config msg
    -> Model
    -> UpdateResponse msg
handleTransfer config model =
    let
        model_ =
            { model | bankState = Transfer }
    in
        ( model_, React.none )


handleTransferError :
    Config msg
    -> Model
    -> UpdateResponse msg
handleTransferError config model =
    let
        model_ =
            { model | error = Just "Transfer Error" }
    in
        ( model_, React.none )
