module Core.Flags exposing (Flags, Mode(..), initFlags, getVersion, getMode, isDev, isHE2)


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


isHE2 : Flags -> Bool
isHE2 { mode } =
    mode == HE2



-- internals


toMode : String -> Mode
toMode mode =
    case mode of
        "HE2" ->
            HE2

        _ ->
            HE1
