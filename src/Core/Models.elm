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
import Apps.Models
import Landing.Models


type alias CoreModel =
    { route : Route
    , requests : Requests.Models.Model
    , game : Game.Models.GameModel
    , os : OS.Models.Model
    , apps : Apps.Models.AppModel
    , landing : Landing.Models.LandModel
    , websocket : Driver.Websocket.Models.Model
    , config : Config
    }


type alias Config =
    { apiHttpUrl : String
    , apiWsUrl : String
    }


type alias Flags =
    { seed : Int
    , apiHttpUrl : String
    , apiWsUrl : String
    }


initialModel :
    Router.Router.Route
    -> Int
    -> String
    -> String
    -> CoreModel
initialModel route seedInt apiHttpUrl apiWsUrl =
    { route = route
    , requests = Requests.Models.initialModel seedInt
    , game = Game.Models.initialModel
    , os = OS.Models.initialModel
    , apps = Apps.Models.initialModel
    , landing = Landing.Models.initialModel
    , websocket = Driver.Websocket.Models.initialModel apiWsUrl
    , config = generateConfig apiHttpUrl apiWsUrl
    }


generateConfig : String -> String -> Config
generateConfig apiHttpUrl apiWsUrl =
    Config
        apiHttpUrl
        apiWsUrl
