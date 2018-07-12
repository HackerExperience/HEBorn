module Apps.Browser.Pages.Bank.Update exposing (update)

import Utils.React as React exposing (React)
import Utils.Maybe as Maybe
import Game.Bank.Models as Bank
import Apps.Browser.Pages.Bank.Config exposing (..)
import Apps.Browser.Pages.Bank.Models exposing (..)
import Apps.Browser.Pages.Bank.Messages exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        HandleLogin sessionId ->
            handleLogin config sessionId model

        HandleLoginError ->
            handleLoginError config model

        SetTransfer ->
            setTransfer config model

        HandleTransferError ->
            handleTransferError config model

        Logout ->
            onLogout config model

        SetLoading ->
            onSetLoading model

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
    React.update <| setUsername str model


onUpdatePasswordField :
    Config msg
    -> String
    -> Model
    -> UpdateResponse msg
onUpdatePasswordField config str model =
    React.update <| setPassword str model


onUpdateTransferBankField :
    Config msg
    -> String
    -> Model
    -> UpdateResponse msg
onUpdateTransferBankField config str model =
    React.update <| setTransferDestinyBankIp str model


onUpdateTransferAccountField :
    Config msg
    -> String
    -> Model
    -> UpdateResponse msg
onUpdateTransferAccountField config str model =
    React.update <| setTransferDestinyAcc str model


onUpdateTransferValueField :
    Config msg
    -> String
    -> Model
    -> UpdateResponse msg
onUpdateTransferValueField config str model =
    React.update <| setTransferValue str model


onSetLoading : Model -> UpdateResponse msg
onSetLoading model =
    ( { model | state = Loading }, React.none )


handleLogin :
    Config msg
    -> String
    -> Model
    -> UpdateResponse msg
handleLogin config sessionId model =
    let
        model_ =
            { model
                | state = Main
                , sessionId = Just sessionId
            }
    in
        ( model_, React.none )


handleLoginError :
    Config msg
    -> Model
    -> UpdateResponse msg
handleLoginError config model =
    React.update <| setLoginError "Invalid Login Information" model


onLogout : Config msg -> Model -> UpdateResponse msg
onLogout config model =
    let
        model_ =
            { model
                | sessionId = Nothing
                , state = Login (LoginInformation Nothing Nothing Nothing)
            }

        mapper =
            flip Bank.getAccountId config.bank

        accountId =
            Maybe.map mapper model.sessionId


        react =
            case Maybe.uncurry accountId model.sessionId of
                Just (accountId, sessionId) ->
                    React.msg <| config.onLogout sessionId

                Nothing ->
                    React.none
    in
        ( model_, react )


setTransfer :
    Config msg
    -> Model
    -> UpdateResponse msg
setTransfer config model =
    let
        model_ =
            { model
                | state =
                    TransferInformation Nothing Nothing Nothing Nothing
                        |> Transfer
            }
    in
        React.update model_


handleTransferError :
    Config msg
    -> Model
    -> UpdateResponse msg
handleTransferError config model =
    React.update <| setTransferError "Transfer Error" model
