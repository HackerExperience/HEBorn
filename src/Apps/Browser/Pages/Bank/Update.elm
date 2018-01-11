module Apps.Browser.Pages.Bank.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Browser.Pages.Bank.Config exposing (..)
import Apps.Browser.Pages.Bank.Models exposing (..)
import Apps.Browser.Pages.Bank.Messages exposing (..)
import Game.Meta.Types.Network exposing (NIP)
import Game.Account.Finances.Models exposing (AccountNumber)
import Requests.Types exposing (ResponseType)
import Game.Account.Finances.Requests.Login as LoginRequest
import Game.Account.Finances.Requests.Transfer as TransferRequest


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update :
    Config msg
    -> Game.Data
    -> Msg
    -> Model
    -> UpdateResponse msg
update config data msg model =
    case msg of
        HandleLogin accData ->
            handleLogin config data accData model

        HandleLoginError ->
            handleLogin config data model

        HandleTransfer ->
            handleTransfer config data model

        HandleTransferError ->
            handleTransferError config data model

        UpdateLoginField str ->
            onUpdateLoginField config data str model

        UpdatePasswordField str ->
            onUpdatePasswordField config data str model

        UpdateTransferBankField str ->
            onUpdateTransferBankField config data str model

        UpdateTransferAccountField str ->
            onUpdateTransferAccountField config data str model

        UpdateTransferValueField str ->
            onUpdateTransferValueField config data str model


onUpdateLoginField :
    Config msg
    -> Game.Data
    -> String
    -> Model
    -> UpdateResponse msg
onUpdateLoginField config data str model =
    if (String.contains "-" str) then
        Update.fromModel model
    else
        Update.fromModel { model | accountNum = Just str }


onUpdatePasswordField :
    Config msg
    -> Game.Data
    -> String
    -> Model
    -> UpdateResponse msg
onUpdatePasswordField config data str model =
    Update.fromModel
        { model | password = Just str }


onUpdateTransferBankField :
    Config msg
    -> Game.Data
    -> String
    -> Model
    -> UpdateResponse msg
onUpdateTransferBankField config data str model =
    if (String.contains "-" str) then
        Update.fromModel model
    else
        Update.fromModel { model | toBankTransfer = Just str }


onUpdateTransferAccountField :
    Config msg
    -> Game.Data
    -> String
    -> Model
    -> UpdateResponse msg
onUpdateTransferAccountField config data str model =
    if (String.contains "-" str) then
        Update.fromModel model
    else
        case (String.toInt str) of
            Result.Ok num ->
                Update.fromModel { model | toAccountTransfer = Just num }

            Result.Err _ ->
                Update.fromModel model


onUpdateTransferValueField :
    Config msg
    -> Game.Data
    -> String
    -> Model
    -> UpdateResponse msg
onUpdateTransferValueField config data str model =
    if (String.contains "-" str) then
        Update.fromModel model
    else
        case (String.toInt str) of
            Result.Ok num ->
                Update.fromModel { model | toAccountTransfer = Just num }

            Result.Err _ ->
                Update.fromModel model


handleLogin :
    Config msg
    -> Game.Data
    -> AccountData
    -> Model
    -> UpdateResponse msg
handleLogin config data accData model =
    let
        model_ =
            { model
                | loggedIn = True
                , bankState = Main
                , accountData = Just accData
                , error = Nothing
            }
    in
        Update.fromModel model_


handleLoginError :
    Config msg
    -> Game.Data
    -> Model
    -> UpdateResponse msg
handleLoginError config data error model =
    Update.fromModel { model | error = Just <| Error "Invalid Login Information" }


handleTransfer :
    Config msg
    -> Game.Data
    -> Model
    -> UpdateResponse msg
handleTransfer config data model =
    let
        model_ =
            { model | bankState = Transfer }
    in
        Update.fromModel model_


handleTransferError :
    Config msg
    -> Game.Data
    -> Model
    -> UpdateResponse msg
handleTransferError config data model =
    let
        model_ =
            { model | error = Just <| Error "Transfer Error" }
    in
        Update.fromModel model_


handleLogout : Config msg -> Game.Data -> Model -> UpdateResponse msg
handleLogout config data model =
    Update.fromModel initialModel
