module Events.BackFlix.Handler exposing (events)

import Events.Shared exposing (Router)
import Core.Dispatch.BackFlix as BackFlix
import Events.BackFlix.Handlers.NewLog as NewLog
import Events.BackFlix.Config exposing (..)


events : Config msg -> Router msg
events config name json =
    case name of
        "new_log" ->
            NewLog.handler config.onNewLog json

        _ ->
            Err "Not implemented or incompatible event router"
