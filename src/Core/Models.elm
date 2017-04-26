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
    { apiUrl : String }


type alias Flags =
    { seed : Int
    , apiUrl : String
    }


initialModel : Router.Router.Route -> Int -> String -> CoreModel
initialModel route seedInt apiUrl =
    { route = route
    , requests = Requests.Models.initialModel seedInt
    , game = Game.Models.initialModel
    , os = OS.Models.initialModel
    , apps = Apps.Models.initialModel
    , landing = Landing.Models.initialModel
    , websocket = Driver.Websocket.Models.initialModel
    , config = generateConfig apiUrl
    }


generateConfig : String -> Config
generateConfig apiUrl =
    Config
        apiUrl
