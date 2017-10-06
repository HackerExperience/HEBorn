module Game.Account.Models
    exposing
        ( Model
        , ID
        , Token
        , Username
        , Email
        , initialModel
        , insertGateway
        , insertEndpoint
        , getToken
        , getGateway
        , getContext
        , getDatabase
        )

import Game.Servers.Shared as Servers
import Game.Account.Database.Models as Database exposing (..)
import Game.Account.Dock.Models as Dock
import Game.Account.Bounces.Models as Bounces
import Game.Account.Inventory.Models as Inventory
import Game.Notifications.Models as Notifications
import Game.Network.Types exposing (NIP)
import Game.Meta.Types exposing (..)


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
    , gateways : List NIP
    , activeGateway : Maybe NIP -- NEVER SET TO NOTHING EXCEPT ON INIT
    , joinedEndpoints : List NIP
    , context : Context
    , bounces : Bounces.Model
    , inventory : Inventory.Model
    , notifications : Notifications.Model
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
    , gateways = []
    , activeGateway = Nothing
    , joinedEndpoints = []
    , context = Gateway
    , bounces = Bounces.initialModel
    , inventory = Inventory.initialModel
    , notifications = Notifications.initialModel
    , logout = False
    }


getToken : Model -> Token
getToken model =
    model.auth.token


getGateway : Model -> Maybe NIP
getGateway =
    .activeGateway


getContext : Model -> Context
getContext =
    .context


getDatabase : Model -> Database.Model
getDatabase =
    .database


insertGateway : NIP -> Model -> Model
insertGateway id ({ gateways } as model) =
    let
        activeGateway =
            if model.activeGateway == Nothing then
                Just id
            else
                model.activeGateway

        gateways =
            if not <| List.member id model.gateways then
                id :: model.gateways
            else
                model.gateways
    in
        { model | activeGateway = activeGateway, gateways = gateways }


insertEndpoint : NIP -> Model -> Model
insertEndpoint nip ({ joinedEndpoints } as model) =
    let
        joinedEndpoints_ =
            if List.member nip joinedEndpoints then
                joinedEndpoints
            else
                nip :: joinedEndpoints
    in
        { model | joinedEndpoints = joinedEndpoints_ }
