module Core.Flags exposing (Flags, initFlags, getVersion)


type alias Flags =
    { apiHttpUrl : String
    , apiWsUrl : String
    , version : String
    }


initFlags : String -> String -> String -> Flags
initFlags apiHttpUrl apiWsUrl version =
    { apiHttpUrl = apiHttpUrl
    , apiWsUrl = apiWsUrl
    , version = version
    }


getVersion : Flags -> String
getVersion =
    .version
