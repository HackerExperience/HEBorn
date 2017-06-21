module Game.Account.Models exposing (..)

import Game.Shared exposing (..)
import Game.Account.Database.Models as Database exposing (..)


type alias AccountID =
    ID


type alias Token =
    String


type alias AuthData =
    { token : Maybe Token }


type alias Model =
    { id : Maybe AccountID
    , username : Maybe String
    , email : Maybe String
    , auth : AuthData
    , database : Database
    }


getToken : Model -> Maybe Token
getToken model =
    model.auth.token


setToken : Model -> Maybe Token -> Model
setToken model token =
    let
        auth_ =
            { token = token }
    in
        { model | auth = auth_ }


isAuthenticated : Model -> Bool
isAuthenticated model =
    case getToken model of
        Nothing ->
            False

        Just _ ->
            True


initialAuth : AuthData
initialAuth =
    { token = Nothing }


initialModel : Model
initialModel =
    { id = Nothing
    , username = Nothing
    , email = Nothing
    , auth = initialAuth
    , database = Database.empty
    }
