module Core.Subscribers.Servers exposing (dispatch)

import Core.Dispatch.Servers exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core
import Game.Messages as Game
import Game.Servers.Messages as Servers
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Shared exposing (CId)


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        Server id dispatch ->
            fromServer id dispatch

        _ ->
            []



-- internals


fromServer : CId -> Server -> Subscribers
fromServer id dispatch =
    case dispatch of
        Filesystem dispatch ->
            fromFilesystem id dispatch

        Logs dispatch ->
            fromLogs id dispatch

        Processes dispatch ->
            fromProcesses id dispatch

        _ ->
            []


fromFilesystem : CId -> Filesystem -> Subscribers
fromFilesystem id dispatch =
    case dispatch of
        _ ->
            []


fromLogs : CId -> Logs -> Subscribers
fromLogs id dispatch =
    case dispatch of
        _ ->
            []


fromProcesses : CId -> Processes -> Subscribers
fromProcesses id dispatch =
    case dispatch of
        StartedProcess a ->
            [ processes id <| Processes.HandleProcessStarted a ]

        ConcludedProcess a ->
            [ processes id <| Processes.HandleProcessConclusion a ]

        ChangedProcesses a ->
            [ processes id <| Processes.HandleProcessesChanged a ]

        FailedBruteforceProcess a ->
            [ processes id <| Processes.HandleBruteforceFailed a ]

        _ ->
            []
