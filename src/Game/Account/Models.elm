module Game.Account.Models
    exposing
        ( Model
        , ID
        , Token
        , Username
        , Email
        , Logout(..)
        , initialModel
        , insertGateway
        , getId
        , getToken
        , getGateway
        , getContext
        , getDatabase
        , getBounces
        , getMainframe
        )

import Core.Error as Error exposing (Error)
import Game.Servers.Shared as Servers
import Game.Account.Database.Models as Database exposing (..)
import Game.Account.Dock.Models as Dock
import Game.Account.Bounces.Models as Bounces
import Game.Account.Inventory.Models as Inventory
import Game.Notifications.Models as Notifications
import Game.Meta.Types.Context exposing (..)
import Game.Meta.Types.Network exposing (NIP)
import Setup.Types as Setup


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


type Logout
    = StillLogged
    | ToLanding
    | ToCrash Error


type alias Model =
    { id : ID
    , username : String
    , auth : AuthData
    , email : Maybe Email
    , database : Database.Model
    , dock : Dock.Model
    , gateways : List Servers.CId
    , activeGateway : Maybe Servers.CId -- NEVER SET TO "NOTHING" (EXCEPT ON INIT)
    , context : Context
    , bounces : Bounces.Model
    , userBounces : List Bounces.ID
    , inventory : Inventory.Model
    , notifications : Notifications.Model
    , logout : Logout
    , mainframe : Maybe Servers.CId
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
    , context = Gateway
    , bounces = Bounces.initialModel
    , userBounces = []
    , inventory = Inventory.initialModel
    , notifications = Notifications.initialModel
    , logout = StillLogged
    , mainframe = Nothing
    }


getId : Model -> ID
getId model =
    model.id


getToken : Model -> Token
getToken model =
    model.auth.token


getGateway : Model -> Maybe Servers.CId
getGateway =
    .activeGateway


getContext : Model -> Context
getContext =
    .context


getDatabase : Model -> Database.Model
getDatabase =
    .database


getBounces : Model -> Bounces.Model
getBounces =
    .bounces


getMainframe : Model -> Maybe Servers.CId
getMainframe =
    .mainframe


insertGateway : Servers.CId -> Model -> Model
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
