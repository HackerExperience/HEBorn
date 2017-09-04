module Game.Servers.Processes.ResultHandler exposing (handle, completeProcess)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Processes.Models as Processes exposing (..)
import Game.Servers.Processes.Types.Shared exposing (..)
import Game.Servers.Processes.Types.Local as Local
import Game.Servers.Processes.Types.Remote as Remote

-- TODO: think of a better way for doing this,

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


handle : String -> ProcessProp -> Dispatch
handle serverID proc =
    case proc of
        Processes.LocalProcess prop ->
            handleLocal serverID prop

        Processes.RemoteProcess prop ->
            handleRemote prop


completeProcess : String -> Processes -> ProcessID -> ( Processes, Dispatch )
completeProcess serverID processes pId =
    -- TODO: do not assume that the process was a success, log doesn't need
    -- a dispatch for that, the server will send 
    let
        ( processes_, prop ) =
            Processes.completeProcess pId processes

        callback =
            prop
                |> Maybe.map (handleLocal serverID)
                |> Maybe.withDefault Dispatch.none
    in
        ( processes_, callback )
