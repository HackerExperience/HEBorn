module Game.Account.Models
    exposing
        ( Model
        , ID
        , Token
        , Username
        , Email
        , initialModel
        , getToken
        , insertServer
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
    , servers : List Servers.ID
    , activeGateway : Servers.ID
    , bounces : Bounces.Model
    , inventory : Inventory.Model
    , logout : Bool
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
    , servers = []
    , activeGateway = ""
    , bounces = Bounces.initialModel
    , inventory = Inventory.initialModel
    , logout = False
    }


getToken : Model -> Token
getToken model =
    model.auth.token


insertServer : Servers.ID -> Model -> Model
insertServer id ({ servers } as model) =
    if not <| List.member id servers then
        { model | servers = id :: servers }
    else
        model
