module Game.Account.Models
    exposing
        ( Model
        , ID
        , Token
        , Username
        , Email
        , initialModel
        , insertServer
        , getToken
        , getGateway
        , getDatabase
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
    , database : Database.Model
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


getGateway : Model -> Servers.ID
getGateway =
    .activeGateway


getDatabase : Model -> Database.Model
getDatabase =
    .database


insertServer : Servers.ID -> Model -> Model
insertServer id ({ servers } as model) =
    let
        activeGateway =
            if model.activeGateway == "" then
                id
            else
                model.activeGateway

        servers =
            if not <| List.member id model.servers then
                id :: model.servers
            else
                model.servers
    in
        { model | activeGateway = activeGateway, servers = servers }
