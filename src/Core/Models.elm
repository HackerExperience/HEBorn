module Core.Models
    exposing
        ( Model
        , Flags
        , initialModel
        )

import Driver.Websocket.Models as Websocket
import Router.Router exposing (Route)
import Game.Models as Game
import OS.Models as OS
import Landing.Models as Landing


type alias Model =
    { route : Route
    , game : Game.Model
    , os : OS.Model
    , landing : Landing.Model
    , websocket : Websocket.Model
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
    -> Model
initialModel route seedInt apiHttpUrl apiWsUrl version =
    let
        game =
            Game.initialModel apiHttpUrl apiWsUrl version
    in
        { route = route
        , game = game
        , os = OS.initialModel game
        , landing = Landing.initialModel
        , websocket = Websocket.initialModel apiWsUrl
        }
