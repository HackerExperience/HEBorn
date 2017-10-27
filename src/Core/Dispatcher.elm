module Core.Dispatcher exposing (dispatch)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Account as Account
import Core.Dispatch.Core as Core
import Core.Dispatch.OS as OS
import Core.Dispatch.Servers as Servers
import Core.Dispatch.Storyline as Storyline
import Core.Dispatch.Websocket as Websocket
import Core.Messages exposing (..)


type alias Dispatcher a =
    a -> List Msg


dispatch : Dispatcher Dispatch
dispatch =
    Dispatch.yield >> List.concatMap fromAction


fromAction : Dispatcher Dispatch.Internal
fromAction =
    let
        handleNoOp =
            []

        handler dispatch =
            case dispatch of
                Dispatch.Account dispatch ->
                    fromAccount dispatch

                Dispatch.Core dispatch ->
                    fromCore dispatch

                Dispatch.OS dispatch ->
                    fromOS dispatch

                Dispatch.Servers dispatch ->
                    fromServers dispatch

                Dispatch.Storyline dispatch ->
                    fromStoryline dispatch

                Dispatch.Websocket dispatch ->
                    fromWebsocket dispatch

                Dispatch.NoOp ->
                    handleNoOp
    in
        handler


fromAccount : Dispatcher Account.Dispatch
fromAccount =
    let
        handleNoOp =
            []

        handler dispatch =
            case dispatch of
                _ ->
                    handleNoOp
    in
        handler


fromCore : Dispatcher Core.Dispatch
fromCore =
    let
        handleNoOp =
            []

        handler dispatch =
            case dispatch of
                Core.Boot a b c ->
                    [ HandleBoot a b c ]

                Core.Crash a b ->
                    [ HandleCrash a b ]

                Core.Shutdown ->
                    [ HandleShutdown ]

                Core.Play ->
                    [ HandlePlay ]

                _ ->
                    handleNoOp
    in
        handler


fromOS : Dispatcher OS.Dispatch
fromOS =
    let
        handleNoOp =
            []

        handler dispatch =
            case dispatch of
                _ ->
                    handleNoOp
    in
        handler


fromServers : Dispatcher Servers.Dispatch
fromServers =
    let
        handleNoOp =
            []

        handler dispatch =
            case dispatch of
                _ ->
                    handleNoOp
    in
        handler


fromFilesystem : Dispatcher Servers.Filesystem
fromFilesystem =
    let
        handleNoOp =
            []

        handler dispatch =
            case dispatch of
                _ ->
                    handleNoOp
    in
        handler


fromLogs : Dispatcher Servers.Logs
fromLogs =
    let
        handleNoOp =
            []

        handler dispatch =
            case dispatch of
                _ ->
                    handleNoOp
    in
        handler


fromProcesess : Dispatcher Servers.Procesess
fromProcesess =
    let
        handleNoOp =
            []

        handler dispatch =
            case dispatch of
                _ ->
                    handleNoOp
    in
        handler


fromStoryline : Dispatcher Storyline.Dispatch
fromStoryline =
    let
        handleNoOp =
            []

        handler dispatch =
            case dispatch of
                _ ->
                    handleNoOp
    in
        handler


fromWebsocket : Dispatcher Websocket.Dispatch
fromWebsocket =
    let
        handleNoOp =
            []

        handler dispatch =
            case dispatch of
                _ ->
                    handleNoOp
    in
        handler
