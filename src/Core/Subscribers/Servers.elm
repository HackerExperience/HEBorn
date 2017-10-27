module Core.Subscribers.Servers exposing (dispatch)

import Core.Dispatch.Servers exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core
import Game.Messages as Game
import Game.Servers.Messages as Servers
import Game.Servers.Shared exposing (CId)


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        Server cid dispatch ->
            fromServer cid dispatch

        _ ->
            []


fromServer : CId -> Server -> Subscribers
fromServer cid dispatch =
    case dispatch of
        Filesystem dispatch ->
            fromFilesystem cid dispatch

        Logs dispatch ->
            fromLogs cid dispatch

        Processes dispatch ->
            fromProcesses cid dispatch

        _ ->
            []


fromFilesystem : CId -> Filesystem -> Subscribers
fromFilesystem cid dispatch =
    case dispatch of
        _ ->
            []


fromLogs : CId -> Logs -> Subscribers
fromLogs cid dispatch =
    case dispatch of
        _ ->
            []


fromProcesses : CId -> Processes -> Subscribers
fromProcesses cid dispatch =
    case dispatch of
        _ ->
            []
