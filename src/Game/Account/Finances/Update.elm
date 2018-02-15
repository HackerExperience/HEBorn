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

        HandleBankAccountLogin cid request requester ->
            handleBankAccountLogin config request requester cid model

        HandleBankAccountTransfer cid request requester ->
            handleBankAccountTransfer config request requester cid model


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
    -> CId
    -> Model
    -> UpdateResponse msg
handleBankAccountLogin config request requester cid model =
    let
        request_ =
            config
                |> Login.request request requester config.accountId cid
                |> Cmd.map config.toMsg
                |> React.cmd
    in
        ( model, request_ )


handleBankAccountTransfer :
    Config msg
    -> BankTransferRequest
    -> Requester
    -> CId
    -> Model
    -> UpdateResponse msg
handleBankAccountTransfer config request requester cid model =
    let
        request_ =
            Transfer.request request requester config.accountId cid config
                |> Cmd.map config.toMsg
                |> React.cmd
    in
        ( model, request_ )


onRequest : Config msg -> RequestMsg -> Model -> UpdateResponse msg
onRequest config data model =
    case data of
        BankLogin requester cid response ->
            onBankLogin config requester cid (Login.receive response) model

        BankTransfer requester cid response ->
            onBankTransfer config requester cid (Transfer.receive response) model


onBankLogin :
    Config msg
    -> Requester
    -> CId
    -> LoginResponse
    -> Model
    -> UpdateResponse msg
onBankLogin config requester cid response model =
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
    -> CId
    -> TransferResponse
    -> Model
    -> UpdateResponse msg
onBankTransfer config requester cid response model =
    case response of
        Successful ->
            ( model
            , React.msg <| config.onBATransferSuccess requester
            )

        Error ->
            ( model
            , React.msg <| config.onBATransferFailed requester
            )
