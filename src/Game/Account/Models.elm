module Game.Account.Models
    exposing
        ( Model
        , ID
        , Token
        , Username
        , Email
        , initialModel
        , getToken
        )

import Game.Servers.Shared as Servers
import Game.Account.Database.Models as Database exposing (..)
import Game.Account.Dock.Models as Dock
import Game.Account.Bounces.Models as Bounces
import Game.Account.Inventory.Models as Inventory


type alias ID =
    String


type alias Username =
    String


type alias Token =
    String


type alias Email =
    String


type alias AuthData =
    { token : Token }


type alias Model =
    { id : ID
    , username : String
    , auth : AuthData
    , email : Maybe Email
    , database : Database
    , dock : Dock.Model
    , logout : Bool
    , servers : List Servers.ID
    , bounces : Bounces.Model
    , inventory : Inventory.Model
    }


initialAuth : Token -> AuthData
initialAuth token =
    { token = token }


initialModel : ID -> Username -> Token -> Model
initialModel id username token =
    { id = id
    , username = username
    , auth = initialAuth token
    , email = Nothing
    , database = Database.initialModel
    , dock = Dock.initialModel
    , logout = False
    , servers = []
    , bounces = Bounces.initialModel
    , inventory = Inventory.initialModel
    }


getToken : Model -> Token
getToken model =
    model.auth.token
