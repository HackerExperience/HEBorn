module Game.Account.Finances.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Utils.Update as Update
import Game.Models as Game
import Game.Data as Game
import Game.Account.Models as Account
import Game.Account.Finances.Messages exposing (..)
import Game.Account.Finances.Models exposing (..)
import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Shared exposing (CId)
import Game.Web.Models as Web
import Game.Meta.Types.Requester exposing (Requester)
import Game.Account.Finances.Requests.Login as Login
import Game.Account.Finances.Requests.Transfer as Transfer


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Request data ->
            onRequest game data model

        HandleBankAccountClosed accountId ->
            handleBankAccountClosed accountId model

        HandleBankAccountUpdated accountId account ->
            handleBankAccountUpdated accountId account model

        HandleBankAccountLogin request requester cid ->
            handleBankAccountLogin game request requester cid model

        HandleBankAccountTransfer request requester cid ->
            handleBankAccountTransfer game request requester cid model


handleBankAccountClosed : AccountId -> Model -> UpdateResponse
handleBankAccountClosed accountId model =
    Update.fromModel <| removeBankAccount accountId model


handleBankAccountUpdated : AccountId -> BankAccount -> Model -> UpdateResponse
handleBankAccountUpdated accountId bankAccount model =
    Update.fromModel <| insertBankAccount accountId bankAccount model


handleBankAccountLogin :
    Game.Model
    -> BankLoginRequest
    -> Requester
    -> CId
    -> Model
    -> UpdateResponse
handleBankAccountLogin game request requester cid model =
    let
        accountId =
            game
                |> Game.getAccount
                |> Account.getId

        request_ =
            Login.request request requester accountId cid game
    in
        ( model, request_, Dispatch.none )


handleBankAccountTransfer :
    Game.Model
    -> BankTransferRequest
    -> Requester
    -> CId
    -> Model
    -> UpdateResponse
handleBankAccountTransfer game request requester cid model =
    let
        accountId =
            game
                |> Game.getAccount
                |> Account.getId

        request_ =
            Transfer.request request requester accountId cid game
    in
        ( model, request_, Dispatch.none )


onRequest : Game.Model -> RequestMsg -> Model -> UpdateResponse
onRequest game data model =
    case data of
        BankLogin requester cid response ->
            onBankLogin game requester cid (Login.receive response) model

        BankTransfer requester cid response ->
            onBankTransfer game requester cid (Transfer.receive response) model


onBankLogin :
    Game.Model
    -> Requester
    -> CId
    -> LoginResponse
    -> Model
    -> UpdateResponse
onBankLogin game requester cid response model =
    case response of
        Valid data ->
            let
                dispatch =
                    Servers.BankAccountLoginSuccessful requester data
                        |> Dispatch.server cid
            in
                ( model, Cmd.none, dispatch )

        DecodeFailed ->
            Update.fromModel model

        Invalid ->
            let
                dispatch =
                    Servers.BankAccountLoginError requester
                        |> Dispatch.server cid
            in
                ( model, Cmd.none, dispatch )


onBankTransfer :
    Game.Model
    -> Requester
    -> CId
    -> TransferResponse
    -> Model
    -> UpdateResponse
onBankTransfer game requester cid response model =
    case response of
        Successful ->
            let
                dispatch =
                    Servers.BankAccountTransferSuccessful requester
                        |> Dispatch.server cid
            in
                ( model, Cmd.none, dispatch )

        Error ->
            let
                dispatch =
                    Servers.BankAccountTransferError requester
                        |> Dispatch.server cid
            in
                ( model, Cmd.none, dispatch )
