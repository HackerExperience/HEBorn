module Events.BackFlix exposing (events)

import Events.Types exposing (Router)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.BackFlix as BackFlix
import Events.BackFlix.Created as Created


events : Router Dispatch
events name json =
    case name of
        "new_log" ->
            Created.handler onLog json

        _ ->
            Err "Not implemented or incompatible event router"


onLog : Created.Data -> Dispatch
onLog =
    BackFlix.Create >> Dispatch.logflix
