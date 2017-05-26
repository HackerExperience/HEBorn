module Core.Models
    exposing
        ( CoreModel
        , Flags
        , initialModel
        )

import Driver.Websocket.Models
import Requests.Models
import Router.Router exposing (Route)
import Game.Models
import OS.Models
import Landing.Models


type alias CoreModel =
    { route : Route
    , requests : Requests.Models.Model
    , game : Game.Models.GameModel
    , os : OS.Models.Model
    , landing : Landing.Models.LandModel
    , websocket : Driver.Websocket.Models.Model
    , config : Config
    }


type alias Config =
    { apiHttpUrl : String
    , apiWsUrl : String
    , version : String
    }


type alias Flags =
    { seed : Int
    , apiHttpUrl : String
    , apiWsUrl : String
    , version : String
    }


initialModel :
    Router.Router.Route
    -> Int
    -> String
    -> String
    -> String
    -> CoreModel
initialModel route seedInt apiHttpUrl apiWsUrl version =
    let
        game =
            Game.Models.initialModel
    in
        { route = route
        , requests = Requests.Models.initialModel seedInt
        , game = game
        , os = OS.Models.initialModel game
        , landing = Landing.Models.initialModel
        , websocket = Driver.Websocket.Models.initialModel apiWsUrl
        , config = generateConfig apiHttpUrl apiWsUrl version
        }


generateConfig : String -> String -> String -> Config
generateConfig apiHttpUrl apiWsUrl version =
    Config
        apiHttpUrl
        apiWsUrl
        version
