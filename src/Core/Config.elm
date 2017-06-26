module Core.Config exposing (Config, init)


type alias Config =
    { apiHttpUrl : String
    , apiWsUrl : String
    , version : String
    }


init : String -> String -> String -> Config
init apiHttpUrl apiWsUrl version =
    { apiHttpUrl = apiHttpUrl
    , apiWsUrl = apiWsUrl
    , version = version
    }
