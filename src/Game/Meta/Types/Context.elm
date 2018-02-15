module Game.Meta.Types.Context exposing (..)


type Context
    = Gateway
    | Endpoint


toString : Context -> String
toString context =
    case context of
        Gateway ->
            "Gateway"

        Endpoint ->
            "Endpoint"
