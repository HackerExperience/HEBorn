module Game.Account.Models
    exposing
        ( Model
        , AccountID
        , Token
        , initialModel
        , getToken
        )

import Game.Shared exposing (..)
import Game.Servers.Shared as Servers
import Game.Account.Database.Models as Database exposing (..)
import Game.Account.Dock.Models as Dock
import Game.Account.Bounces.Models as Bounces


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
    , dock : Dock.Model
    , logout : Bool
    , servers : List Servers.ID
    , bounces : Bounces.Model
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
    , database = Database.initialModel
    , dock = Dock.initialModel
    , logout = False
    , servers = []
    , bounces = Bounces.initialModel
    }


getToken : Model -> Token
getToken model =
    model.auth.token
