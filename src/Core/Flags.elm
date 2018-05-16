module Core.Flags exposing (Flags, Mode(..), initFlags, getVersion, getMode, isDev)


type Mode
    = HE1
    | HE2


type alias Flags =
    { apiHttpUrl : String
    , apiWsUrl : String
    , version : String
    , mode : Mode
    }


initFlags : String -> String -> String -> String -> Flags
initFlags apiHttpUrl apiWsUrl version mode =
    { apiHttpUrl = apiHttpUrl
    , apiWsUrl = apiWsUrl
    , version = version
    , mode = toMode mode
    }


getVersion : Flags -> String
getVersion =
    .version


getMode : Flags -> Mode
getMode =
    .mode


isDev : Flags -> Bool
isDev { version } =
    version == "dev"



-- internals


toMode : String -> Mode
toMode mode =
    case mode of
        "HE2" ->
            HE2

        _ ->
            HE1
