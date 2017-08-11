module Game.Servers.Processes.ResultHandler exposing (handle, completeProcess)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Processes.Models as Processes exposing (..)
import Game.Servers.Processes.Types.Shared exposing (..)
import Game.Servers.Processes.Types.Local as Local exposing (..)
import Game.Servers.Processes.Types.Remote as Remote exposing (..)


handleLogForge : String -> TargetLogID -> LogForgeAction -> Dispatch
handleLogForge serverID logId logAction =
    case logAction of
        LogCrypt ->
            Dispatch.logs serverID (Logs.LogMsg logId <| Logs.Encrypt)

        _ ->
            Dispatch.none


handleLocal : String -> Local.ProcessProp -> Dispatch
handleLocal serverID prop =
    case prop.processType of
        Local.LogForge forgeVer logId logAction ->
            handleLogForge serverID logId logAction

        _ ->
            Dispatch.none


handleRemote : Remote.ProcessProp -> Dispatch
handleRemote _ =
    Dispatch.none


handle : String -> Process -> Dispatch
handle serverID proc =
    case proc.prop of
        Processes.LocalProcess prop ->
            handleLocal serverID prop

        Processes.RemoteProcess prop ->
            handleRemote prop


completeProcess : String -> Processes -> Process -> ( Processes, Dispatch )
completeProcess serverID processes process =
    let
        processes_ =
            Processes.completeProcess processes process

        callback =
            handle serverID process
    in
        ( processes_, callback )
