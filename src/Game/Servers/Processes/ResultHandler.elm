module Game.Servers.Processes.ResultHandler exposing (handle, completeProcess)

import Core.Messages as Core
import Core.Dispatcher exposing (callLogs)
import Game.Servers.Logs.Messages as Logs exposing (Msg(..))
import Game.Servers.Processes.Models as Processes exposing (..)
import Game.Servers.Processes.Types.Shared exposing (..)
import Game.Servers.Processes.Types.Local as Local exposing (..)
import Game.Servers.Processes.Types.Remote as Remote exposing (..)


handleLogForge : TargetLogID -> LogForgeAction -> List Core.Msg
handleLogForge logId logAction =
    case logAction of
        LogCrypt ->
            [ callLogs
                "localhost"
                (Logs.Crypt logId)
            ]

        _ ->
            []


handleLocal : Local.ProcessProp -> List Core.Msg
handleLocal prop =
    case prop.processType of
        Local.LogForge forgeVer logId logAction ->
            handleLogForge logId logAction

        _ ->
            []


handleRemote : Remote.ProcessProp -> List Core.Msg
handleRemote _ =
    []


handle : Process -> List Core.Msg
handle proc =
    case proc.prop of
        Processes.LocalProcess prop ->
            handleLocal prop

        Processes.RemoteProcess prop ->
            handleRemote prop


completeProcess : Processes -> Process -> ( Processes, List Core.Msg )
completeProcess processes process =
    let
        processes_ =
            Processes.completeProcess processes process

        callback =
            handle process
    in
        ( processes_, callback )
