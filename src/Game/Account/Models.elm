module Game.Account.Models exposing (..)

import Game.Shared exposing (..)


type alias AccountID =
    ID


type alias Token =
    String


type alias AuthData =
    { token : Maybe Token }


type alias AccountModel =
    { id : Maybe AccountID
    , username : Maybe String
    , email : Maybe String
    , auth : AuthData
    }


getToken : AccountModel -> Maybe Token
getToken model =
    model.auth.token


setToken : AccountModel -> Maybe Token -> AccountModel
setToken model token =
    let
        auth_ =
            { token = token }
    in
        { model | auth = auth_ }


isAuthenticated : AccountModel -> Bool
isAuthenticated model =
    case getToken model of
        Nothing ->
            False

        Just _ ->
            True


initialAuth : AuthData
initialAuth =
    { token = Nothing }


initialAccountModel : AccountModel
initialAccountModel =
    { id = Nothing
    , username = Nothing
    , email = Nothing
    , auth = initialAuth
    }
