module Game.Account.Finances.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Models as Game
import Game.Data as Game
import Game.Account.Finances.Messages exposing (..)
import Game.Account.Finances.Models exposing (..)
import Game.Meta.Types.Network exposing (NIP)
import Apps.Reference exposing (Reference)
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

        HandleBankAccountLogin login password reference ->
            handleBankAccountLogin login password reference model

        HandleBankAccountTransfer data fromBank fromAcc toBank toAcc password value ->
            handleBankAccountTransfer data fromBank fromAcc toBank toAcc password value model


handleBankAccountClosed : AccountId -> Model -> UpdateResponse
handleBankAccountClosed accountId model =
    Update.fromModel <| removeBankAccount accountId model


handleBankAccountUpdated : AccountId -> BankAccount -> Model -> UpdateResponse
handleBankAccountUpdated accountId bankAccount model =
    Update.fromModel <| insertBankAccount accountId bankAccount model


handleBankAccountLogin :
    Game.Data
    -> NIP
    -> AccountNumber
    -> String
    -> Config
    -> Model
    -> UpdateResponse
handleBankAccountLogin data bank login password requester model =
    let
        request =
            LoginRequest.request data bank login password requester data
    in
        ( model, request, Dispatch.none )


handleBankAccountTransfer :
    Game.Data
    -> NIP
    -> AccountNumber
    -> NIP
    -> AccountNumber
    -> String
    -> Int
    -> Reference
    -> Model
    -> UpdateResponse
handleBankAccountTransfer data fromBank fromAcc toBank toAcc password value requester model =
    let
        request =
            TransferRequest.request
                fromBank
                fromAccount
                toBank
                toAccount
                password
                value
                requester
                data
    in
        ( model, request, Dispatch.none )


onRequest : Game.Model -> RequestMsg -> Model -> UpdateResponse
onRequest game data model =
    case data of
        RequestMsg (Login requester (Just response)) ->
            onBankLogin game requester (Login.receive response) model

        RequestMsg (Transfer requester (Just response)) ->
            onBankTransfer game requester (Transfer.receive response) model

        _ ->
            Update.fromModel model


onBankLogin :
    Game.Model
    -> Reference
    -> Login.Response
    -> Model
    -> UpdateResponse
onBankLogin game requester response model =
    case response of
        Login.Valid data ->
            let
                dispatch =
                    Dispatch.server cid <|
                        Servers.BankAccountLoginSuccessful requester data
            in
                ( model, Cmd.none, dispatch )

        Login.Invalid ->
            let
                dispatch =
                    Dispatch.server cid <|
                        Servers.BankAccountLoginError requester
            in
                ( model, Cmd.none, dispatch )


onBankTransfer :
    Game.Model
    -> Reference
    -> Transfer.Response
    -> Model
    -> UpdateResponse
onBankTransfer game requester response model =
    case response of
        Transfer.Successful ->
            let
                dispatch =
                    Dispatch.server cid <|
                        Servers.BankAccountTransferSuccessful requester
            in
                ( model, Cmd.none, dispatch )

        Transfer.Error ->
            let
                dispatch =
                    Dispatch.server cid <|
                        Servers.BankAccountTransferError requester
            in
                ( model, Cmd.none, dispatch )
