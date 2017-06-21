module Game.Meta.Models exposing (..)

import Core.Config exposing (Config)
import Time exposing (Time)


type alias Model =
    { online : Int
    , config : Config
    , lastTick : Time
    }


initialModel : String -> String -> String -> Model
initialModel apiHttpUrl apiWsUrl version =
    { online = 0
    , config = generateConfig apiHttpUrl apiWsUrl version
    , lastTick = 0
    }


generateConfig : String -> String -> String -> Config
generateConfig apiHttpUrl apiWsUrl version =
    Config
        apiHttpUrl
        apiWsUrl
        version
