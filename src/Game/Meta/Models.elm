module Game.Meta.Models exposing (..)

import Core.Config exposing (Config)
import Time exposing (Time)


type alias MetaModel =
    { online : Int
    , config : Config
    , lastTick : Time
    }


initialMetaModel : String -> String -> String -> MetaModel
initialMetaModel apiHttpUrl apiWsUrl version =
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
