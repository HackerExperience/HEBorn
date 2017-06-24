module Game.Account.Models
    exposing
        ( Model
        , AccountID
        , Token
        , initialModel
        , getToken
        )

import Game.Shared exposing (..)
import Game.Account.Database.Models as Database exposing (..)


type alias AccountID =
    ID


type alias Token =
    String


type alias AuthData =
    { token : Token }


type alias Model =
    { id : Maybe AccountID
    , username : Maybe String
    , email : Maybe String
    , auth : AuthData
    , database : Database
    }


initialAuth : Token -> AuthData
initialAuth token =
    { token = token }


initialModel : Token -> Model
initialModel token =
    { id = Nothing
    , username = Nothing
    , email = Nothing
    , auth = initialAuth token
    , database = Database.empty
    }


getToken : Model -> Token
getToken model =
    model.auth.token
