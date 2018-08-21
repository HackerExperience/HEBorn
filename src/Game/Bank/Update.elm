module Game.Bank.Update exposing (update)

import Json.Encode as Encode exposing (Value)
import Json.Decode exposing (decodeValue)
import Dict as Dict
import Time exposing (Time)
import Task exposing (..)
import Utils.React as React exposing (React)
import Utils.Model.RandomUuid as Random
import Decoders.Bank as Decoder
import Game.Account.Finances.Models as Finances 
    exposing 
        (AccountId
        , AtmId
        , AccountNumber
        )
import Game.Account.Database.Models exposing (Token)
import Game.Bank.Config exposing (..)
import Game.Bank.Models exposing (..)
import Game.Bank.Messages exposing (..)
import Game.Bank.Requests.CreateAccount as CreateAccountRequest
import Game.Bank.Requests.CloseAccount as CloseAccountRequest
import Game.Bank.Requests.Resync as ResyncRequest
import Game.Bank.Requests.Transfer as TransferRequest
import Game.Bank.Requests.ChangePassword as ChangePasswordRequest
import Game.Bank.Requests.RevealPassword as RevealPasswordRequest
import Game.Bank.Requests.Logout as LogoutRequest
import Game.Meta.Types.Desktop.Apps exposing (Requester)
import Game.Meta.Types.Network exposing (IP)
import Game.Servers.Shared exposing (CId(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        HandleLogin accountId password requester ->
            handleLogin config accountId password requester model

        HandleLoginToken accountId token requester ->
            handleLoginToken config accountId token requester model

        HandleLoggedIn accountId balance password ->
            handleLoggedIn config accountId balance password model

        HandleJoinedBank requestId data ->
            handleJoinedBank config requestId data model

        HandleCreateAccount atmId requester ->
            handleCreateAccount config atmId requester model

        HandleCloseAccount sessionId requester ->
            handleCloseAccount config sessionId requester model

        HandleChangePassword sessionId requester ->
            handleChangePassword config sessionId requester model

        HandleTransfer sessionId targetBank targetAcc value requester ->
            handleTransfer config sessionId targetBank targetAcc value requester model

        HandleRevealPassword sessionId token requester ->
            handleRevealPassword config sessionId token requester model

        HandleResync sessionId requester ->
            handleResync config sessionId requester model

        HandleLogout sessionId requester ->
            handleLogout config sessionId requester model

        UpdateCache sessionId data ->
            React.update model


handleLogin :
    Config msg
    -> AccountId
    -> String
    -> Requester
    -> Model
    -> UpdateResponse msg
handleLogin config bankAccId password requester model =
    let
        accountId =
            config.accountId

        gatewayId =
            config.activeGatewayCId

        bounceId =
            config.activeBounce

        ( model_, requestId ) =
            Random.newUuid model
        
        model0 =
            addWaitingId requestId bankAccId model_

        ( atmId, accNum ) =
            bankAccId

        react =
            case gatewayId of
                Just (GatewayCId serverId) ->
                    React.batch
                        config.batchMsg
                        [ config.onLogin bankAccId requestId (payload serverId)
                            |> React.msg
                        , loginMsg config requestId requester
                            |> loginEventReaction config requestId
                        ]

                _ ->
                    React.none

        payload serverId =
            let
                baseList =
                    [ ( "gateway_id", Encode.string serverId )
                    , ( "entity_id", Encode.string accountId )
                    , ( "password", Encode.string password )
                    , ( "request_id", Encode.string requestId )
                    ]

                list =
                    case bounceId of
                        Just bounceId ->
                            ( "bounce_id", Encode.string bounceId ) :: baseList

                        Nothing ->
                            baseList
            in
                Encode.object list
    in
        ( model0, react )


handleLoginToken :
    Config msg
    -> AccountId
    -> String
    -> Requester
    -> Model
    -> UpdateResponse msg
handleLoginToken config bankAccId token requester model =
    let
        accountId =
            config.accountId

        gatewayId =
            config.activeGatewayCId

        bounceId =
            config.activeBounce

        ( model_, requestId ) =
            Random.newUuid model

        ( atmId, accNum ) =
            bankAccId

        react =
            case gatewayId of
                Just (GatewayCId serverId) ->
                    React.batch
                        config.batchMsg
                        [ config.onLogin bankAccId requestId (payload serverId)
                            |> React.msg
                        , loginMsg config requestId requester
                            |> loginEventReaction config requestId
                        ]

                _ ->
                    React.none

        payload serverId =
            let
                baseList =
                    [ ( "gateway_id", Encode.string serverId )
                    , ( "entity_id", Encode.string accountId )
                    , ( "token", Encode.string token )
                    , ( "request_id", Encode.string requestId )
                    ]

                list =
                    case bounceId of
                        Just bounceId ->
                            ( "bounce_id", Encode.string bounceId ) :: baseList

                        Nothing ->
                            baseList
            in
                Encode.object list
    in
        ( model, react )

handleLoggedIn : 
    Config msg 
    -> AccountId
    -> Int
    -> String
    -> Model 
    -> UpdateResponse msg
handleLoggedIn config accId balance pass model =
    let
        hackedBankAccount time =
            { name = "Bank Louco"
            , password = Just pass
            , knownBalance = Just balance
            , token = Nothing
            , notes = Nothing
            , lastLoginDate = Nothing
            , lastUpdate = time 
            }

        onHackedBankAccount = 
            hackedBankAccount >> config.onHackedBankAccountUpdated accId
    in     
        case Dict.get accId <| Finances.getBankAccounts config.finances of
            Just _ ->
                let
                    acc = 
                        { name = "Bank Louco"
                        , password = pass
                        , balance = balance
                        }
                in
                    (model, React.msg <| config.onBankAccountUpdated accId acc)

            Nothing ->
                (model, React.cmd  <| Task.perform onHackedBankAccount Time.now) 
                
                



handleJoinedBank :
    Config msg
    -> String
    -> Value
    -> Model
    -> UpdateResponse msg
handleJoinedBank config requestId data model =
    let
        data_ =
            decodeValue Decoder.accountData data

        model_ =
            case data_ of
                Ok data ->
                    startNewSession requestId data model
                Err _ ->
                    model
    in
        React.update model_


handleCreateAccount :
    Config msg
    -> AtmId
    -> Requester
    -> Model
    -> UpdateResponse msg
handleCreateAccount ({ accountId } as config) atmId requester model =
    let
        request =
            CreateAccountRequest.createAccountRequest

        callback cid =
            config
                |> request accountId atmId cid
                |> React.cmd
                |> React.map (\a -> config.batchMsg [])
    in
        React.maybeUpdate callback config.activeGatewayCId model


handleCloseAccount :
    Config msg
    -> String
    -> Requester
    -> Model
    -> UpdateResponse msg
handleCloseAccount config sessionId requester model =
    let
        callback bankAccId =
            CloseAccountRequest.closeAccountRequest bankAccId sessionId config
                |> React.cmd
                |> React.map (\a -> config.batchMsg [])
    in
        getAccIdAndRequest callback sessionId model


handleChangePassword :
    Config msg
    -> String
    -> Requester
    -> Model
    -> UpdateResponse msg
handleChangePassword config sId requester model =
    let
        callback bankAccId =
            ChangePasswordRequest.changePasswordRequest bankAccId sId config
                |> React.cmd
                |> React.map (\a -> config.batchMsg [])
    in
        getAccIdAndRequest callback sId model


handleTransfer :
    Config msg
    -> String
    -> IP
    -> AccountNumber
    -> Int
    -> Requester
    -> Model
    -> UpdateResponse msg
handleTransfer config sId bIp accNumber value requester model =
    let
        callback bId =
            config
                |> TransferRequest.transferRequest bId sId accNumber bIp value
                |> React.cmd
                |> React.map (\a -> config.batchMsg [])
    in
        getAccIdAndRequest callback sId model


handleRevealPassword :
    Config msg
    -> String
    -> Token
    -> Requester
    -> Model
    -> UpdateResponse msg
handleRevealPassword config sessionId token requester model =
    let
        callback cid =
            RevealPasswordRequest.revealPasswordRequest cid token config
                |> React.cmd
                -- TODO: Enviar uma mensagem para o requester para ele poder
                -- dar feedback visual
                |> React.map (\a -> config.batchMsg [])

        session =
            getSession sessionId model
    in
        case Maybe.map mapSessionToAccId session of
            Just _ ->
                React.maybeUpdate callback config.activeGatewayCId model

            Nothing ->
                React.update model


handleResync : Config msg -> String -> Requester -> Model -> UpdateResponse msg
handleResync ({ toMsg } as config) sessionId requester model =
    let
        callback bankAccId =
            ResyncRequest.resyncRequest bankAccId sessionId config
                |> React.cmd
                |> React.map (\a -> config.batchMsg [])

        --UpdateCache sessionId >> toMsg)
    in
        getAccIdAndRequest callback sessionId model


handleLogout : Config msg -> String -> Requester -> Model -> UpdateResponse msg
handleLogout config sessionId requester model =
    let
        callback bankAccId =
            LogoutRequest.logoutRequest bankAccId sessionId config
                |> React.cmd
                |> React.map (\a -> config.onLogout bankAccId sessionId)
    in
        getAccIdAndRequest callback sessionId model


getAccIdAndRequest :
    (AccountId -> React msg)
    -> String
    -> Model
    -> UpdateResponse msg
getAccIdAndRequest callback sessionId model =
    model
        |> getSession sessionId
        |> Maybe.map mapSessionToAccId
        |> flip (React.maybeUpdate callback) model


loginEventReaction : Config msg -> String -> msg -> React msg
loginEventReaction config requestId msg =
    ( "bank_login", msg )
        |> config.awaitEvent requestId
        |> React.msg


loginMsg : Config msg -> String -> Requester -> msg
loginMsg { onSendSessionId, batchMsg } requestId requester =
    onSendSessionId requestId requester


mapSessionToAccId : BankSession -> AccountId
mapSessionToAccId session =
    ( session.atmId, session.accountNumber )
