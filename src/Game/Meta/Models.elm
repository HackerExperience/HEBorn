module Game.Meta.Models exposing (..)

import Core.Config exposing (Config)


type alias MetaModel =
    { online : Int
    , config : Config
    }


initialMetaModel : String -> String -> String -> MetaModel
initialMetaModel apiHttpUrl apiWsUrl version =
    { online = 0
    , config = generateConfig apiHttpUrl apiWsUrl version
    }


generateConfig : String -> String -> String -> Config
generateConfig apiHttpUrl apiWsUrl version =
    Config
        apiHttpUrl
        apiWsUrl
        version
