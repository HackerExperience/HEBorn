module OS.SessionManager.WindowManager.Context exposing (toString)

import Game.Meta.Types exposing (Context(..))


toString : Maybe Context -> String
toString context =
    case context of
        Just Gateway ->
            "Gateway"

        Just Endpoint ->
            "Endpoint"

        Nothing ->
            ""
