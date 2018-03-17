module Events.BackFlix.Handler exposing (events)

import Events.Shared exposing (Router)
import Events.BackFlix.Handlers.NewLog as NewLog
import Events.BackFlix.Config exposing (..)


events : Config msg -> String -> Router msg
events config requestId name json =
    case name of
        "new_log" ->
            NewLog.handler config.onNewLog json

        _ ->
            Err "Not implemented or incompatible event router"
