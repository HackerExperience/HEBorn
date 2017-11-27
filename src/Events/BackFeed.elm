module Events.BackFeed exposing (events)

import Events.Types exposing (Router)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.BackFeed as LogFlix
import Events.BackFeed.Created as Created


events : Router Dispatch
events name json =
    case name of
        "new_log" ->
            Created.handler onLog json

        _ ->
            Err "Not implemented or incompatible event router"


onLog : Created.Data -> Dispatch
onLog =
    let
        _ =
            Debug.log "Chegou em onLog"
    in
        LogFlix.Create >> Dispatch.logflix
