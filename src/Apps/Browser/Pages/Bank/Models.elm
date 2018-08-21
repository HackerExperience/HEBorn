module Apps.Browser.Pages.Bank.Models exposing (..)

import Game.Meta.Types.Network.Site as Site
import Game.Meta.Types.Network exposing (IP)
import Game.Account.Finances.Models exposing (AccountNumber, AtmId)


type alias Model =
    { title : String
    , atmId : AtmId
    , sessionId : Maybe String
    , state : State
    }


type alias LoginInformation =
    { login : Maybe Int
    , password : Maybe String
    , error : Maybe String
    }


type alias TransferInformation =
    { destinyAccount : Maybe AccountNumber
    , destinyBank : Maybe IP
    , value : Maybe Int
    , error : Maybe String
    }



-- Imposto é roubo


type State
    = Login LoginInformation
    | Main
    | Loading
    | Transfer TransferInformation
    | TransferSuccess


initialModel : Site.Url -> Site.BankContent -> Model
initialModel url content =
    { title = content.title
    , atmId = content.atmId
    , sessionId = Nothing
    , state = Login (LoginInformation Nothing Nothing Nothing)
    }



-- Getters and Setters


getTitle : Model -> String
getTitle { title } =
    title ++ " Bank"


getUsername : Model -> Maybe Int
getUsername model =
    case model.state of
        Login info ->
            info.login

        _ ->
            Nothing


getPassword : Model -> Maybe String
getPassword model =
    case model.state of
        Login info ->
            info.password

        _ ->
            Nothing


getLoginError : Model -> Maybe String
getLoginError model =
    case model.state of
        Login info ->
            info.error

        _ ->
            Nothing


getTransferDestinyBankIp : Model -> Maybe IP
getTransferDestinyBankIp model =
    case model.state of
        Transfer info ->
            info.destinyBank

        _ ->
            Nothing


getTransferDestinyAcc : Model -> Maybe Int
getTransferDestinyAcc model =
    case model.state of
        Transfer info ->
            info.destinyAccount

        _ ->
            Nothing


getTransferValue : Model -> Maybe Int
getTransferValue model =
    case model.state of
        Transfer info ->
            info.value

        _ ->
            Nothing


getTransferError : Model -> Maybe String
getTransferError model =
    case model.state of
        Transfer info ->
            info.error

        _ ->
            Nothing


setUsername : String -> Model -> Model
setUsername string model =
    case model.state of
        Login info ->
            if String.isEmpty string then
                { model | state = Login { info | login = Nothing } }
            else
                let
                    newUsername =
                        Just <| Result.withDefault 0 <| String.toInt string
                in
                    if String.length string > 6 then
                        model
                    else
                        { model | state = Login { info | login = newUsername } }

        _ ->
            model


setPassword : String -> Model -> Model
setPassword string model =
    case model.state of
        Login info ->
            if String.isEmpty string then
                { model | state = Login { info | password = Nothing } }
            else
                { model | state = Login { info | password = Just string } }

        _ ->
            model


setLoginError : String -> Model -> Model
setLoginError string model =
    case model.state of
        Login info ->
            if String.isEmpty string then
                { model | state = Login { info | error = Nothing } }
            else
                { model | state = Login { info | error = Just string } }

        _ ->
            model


setTransferDestinyBankIp : IP -> Model -> Model
setTransferDestinyBankIp ip model =
    case model.state of
        Transfer info ->
            if String.isEmpty ip then
                { model | state = Transfer { info | destinyBank = Nothing } }
            else
                { model | state = Transfer { info | destinyBank = Just ip } }

        _ ->
            model


setTransferDestinyAcc : String -> Model -> Model
setTransferDestinyAcc string model =
    case model.state of
        Transfer info ->
            if String.isEmpty string then
                { model | state = Transfer { info | destinyAccount = Nothing } }
            else
                let
                    acc =
                        Just <| Result.withDefault 0 <| String.toInt string
                in
                    { model | state = Transfer { info | destinyAccount = acc } }

        _ ->
            model


setTransferValue : String -> Model -> Model
setTransferValue string model =
    case model.state of
        Transfer info ->
            if String.isEmpty string then
                { model | state = Transfer { info | value = Nothing } }
            else
                let
                    value =
                        Just <| Result.withDefault 0 <| String.toInt string
                in
                    { model | state = Transfer { info | value = value } }

        _ ->
            model


setTransferError : String -> Model -> Model
setTransferError string model =
    case model.state of
        Transfer info ->
            if String.isEmpty string then
                { model | state = Transfer { info | error = Nothing } }
            else
                { model | state = Transfer { info | error = Just string } }

        _ ->
            model


isLogged : Model -> Bool
isLogged model =
    case model.sessionId of
        Just _ ->
            True

        Nothing ->
            False
