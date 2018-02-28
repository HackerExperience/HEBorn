module Game.Account.Finances.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Servers.Shared exposing (CId)
import Game.Meta.Types.Apps.Desktop exposing (Requester)
import Game.Account.Finances.Config exposing (..)
import Game.Account.Finances.Models exposing (..)
import Game.Account.Finances.Messages exposing (..)
import Game.Account.Finances.Requests.Login as Login
import Game.Account.Finances.Requests.Transfer as Transfer


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        Request data ->
            onRequest config data model

        HandleBankAccountClosed accountId ->
            handleBankAccountClosed accountId model

        HandleBankAccountUpdated accountId account ->
            handleBankAccountUpdated accountId account model

        HandleBankAccountLogin request requester ->
            handleBankAccountLogin config request requester model

        HandleBankAccountTransfer request requester ->
            handleBankAccountTransfer config request requester model


handleBankAccountClosed : AccountId -> Model -> UpdateResponse msg
handleBankAccountClosed accountId model =
    ( removeBankAccount accountId model, React.none )


handleBankAccountUpdated : AccountId -> BankAccount -> Model -> UpdateResponse msg
handleBankAccountUpdated accountId bankAccount model =
    ( insertBankAccount accountId bankAccount model, React.none )


handleBankAccountLogin :
    Config msg
    -> BankLoginRequest
    -> Requester
    -> Model
    -> UpdateResponse msg
handleBankAccountLogin config request requester model =
    let
        request_ =
            config
                |> Login.request request requester config.accountId
                |> Cmd.map config.toMsg
                |> React.cmd
    in
        ( model, request_ )


handleBankAccountTransfer :
    Config msg
    -> BankTransferRequest
    -> Requester
    -> Model
    -> UpdateResponse msg
handleBankAccountTransfer config request requester model =
    let
        request_ =
            Transfer.request request requester config.accountId config
                |> Cmd.map config.toMsg
                |> React.cmd
    in
        ( model, request_ )


onRequest : Config msg -> RequestMsg -> Model -> UpdateResponse msg
onRequest config data model =
    case data of
        BankLogin requester response ->
            onBankLogin config requester (Login.receive response) model

        BankTransfer requester response ->
            onBankTransfer config requester (Transfer.receive response) model


onBankLogin :
    Config msg
    -> Requester
    -> LoginResponse
    -> Model
    -> UpdateResponse msg
onBankLogin config requester response model =
    case response of
        Valid data ->
            ( model
            , React.msg <| config.onBALoginSuccess data requester
            )

        DecodeFailed ->
            ( model, React.none )

        Invalid ->
            ( model
            , React.msg <| config.onBALoginFailed requester
            )


onBankTransfer :
    Config msg
    -> Requester
    -> TransferResponse
    -> Model
    -> UpdateResponse msg
onBankTransfer config requester response model =
    case response of
        Successful ->
            ( model
            , React.msg <| config.onBATransferSuccess requester
            )

        Error ->
            ( model
            , React.msg <| config.onBATransferFailed requester
            )
