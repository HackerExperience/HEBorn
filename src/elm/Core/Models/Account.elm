module Core.Models.Account exposing (..)


import Core.Models.Shared exposing (..)


type alias AccountID =
    ID

type alias AuthData =
    {token : Maybe String}

type alias AccountModel =
    { id : Maybe AccountID
    , username : Maybe String
    , email : Maybe String
    , auth : AuthData
    }

getToken : AccountModel -> Maybe String
getToken model =
    model.auth.token

setToken : AccountModel -> Maybe String -> AccountModel
setToken model token =
    let
        auth_ = {token = token}
    in
        {model | auth = auth_}

isAuthenticated : AccountModel -> Bool
isAuthenticated model =
    case getToken model of
        Nothing ->
            False

        Just _ ->
            True


getTokenAsString : AccountModel -> String
getTokenAsString model =
    case getToken model of
        Just token ->
            token

        Nothing ->
            ""


initialAuth : AuthData
initialAuth =
    {token = Nothing}


initialAccountModel : AccountModel
initialAccountModel =
    { id = Nothing
    , username = Nothing
    , email = Nothing
    , auth = initialAuth
    }

