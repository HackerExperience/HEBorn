module Core.Models
    exposing
        ( CoreModel
        , Flags
        , initialModel
        )

import Driver.Websocket.Models
import Router.Router exposing (Route)
import Game.Models
import OS.Models
import Landing.Models


type alias CoreModel =
    { route : Route
    , game : Game.Models.GameModel
    , os : OS.Models.Model
    , landing : Landing.Models.LandModel
    , websocket : Driver.Websocket.Models.Model
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
            Game.Models.initialModel apiHttpUrl apiWsUrl version
    in
        { route = route
        , game = game
        , os = OS.Models.initialModel game
        , landing = Landing.Models.initialModel
        , websocket = Driver.Websocket.Models.initialModel apiWsUrl
        }
