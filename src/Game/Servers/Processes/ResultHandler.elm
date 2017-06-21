module Game.Servers.Processes.ResultHandler exposing (handle, completeProcess)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Servers.Logs.Messages as Logs exposing (Msg(..))
import Game.Servers.Processes.Models as Processes exposing (..)
import Game.Servers.Processes.Types.Shared exposing (..)
import Game.Servers.Processes.Types.Local as Local exposing (..)
import Game.Servers.Processes.Types.Remote as Remote exposing (..)


handleLogForge : TargetLogID -> LogForgeAction -> Dispatch
handleLogForge logId logAction =
    case logAction of
        LogCrypt ->
            Dispatch.logs
                "localhost"
                (Logs.Crypt logId)

        _ ->
            Dispatch.none


handleLocal : Local.ProcessProp -> Dispatch
handleLocal prop =
    case prop.processType of
        Local.LogForge forgeVer logId logAction ->
            handleLogForge logId logAction

        _ ->
            Dispatch.none


handleRemote : Remote.ProcessProp -> Dispatch
handleRemote _ =
    Dispatch.none


handle : Process -> Dispatch
handle proc =
    case proc.prop of
        Processes.LocalProcess prop ->
            handleLocal prop

        Processes.RemoteProcess prop ->
            handleRemote prop


completeProcess : Processes -> Process -> ( Processes, Dispatch )
completeProcess processes process =
    let
        processes_ =
            Processes.completeProcess processes process

        callback =
            handle process
    in
        ( processes_, callback )
