module Core.Config exposing (Config)


type alias Config =
    { apiHttpUrl : String
    , apiWsUrl : String
    , version : String
    }
