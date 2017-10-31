module Events.Server exposing (events)

import Events.Types exposing (Router)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Servers.Shared exposing (CId)
import Events.Server.Filesystem.NewFile as NewFile
import Events.Server.Logs.Changed as LogsChanged
import Events.Server.Processes.Started as ProcessStarted
import Events.Server.Processes.Conclusion as ProcessConclusion
import Events.Server.Processes.BruteforceFailed as BruteforceFailed
import Events.Server.Processes.Changed as ProcessesChanged


events : CId -> Router Dispatch
events cid name json =
    case name of
        "new_file" ->
            NewFile.handler (onNewFile cid) json

        "log_changed" ->
            LogsChanged.handler (onLogsChanged cid) json

        "process_started" ->
            ProcessStarted.handler (onProcessStarted cid) json

        "process_conclusion" ->
            ProcessConclusion.handler (onProcessConclusion cid) json

        "processes_changed" ->
            ProcessesChanged.handler (onProcessesChanged cid) json

        "bruteforce_failed" ->
            BruteforceFailed.handler (onBruteforceFailed cid) json

        _ ->
            Err ""



-- internals


onNewFile : CId -> NewFile.Data -> Dispatch
onNewFile id =
    Servers.CreatedNewFile >> Dispatch.filesystem_ id


onLogsChanged : CId -> LogsChanged.Data -> Dispatch
onLogsChanged id =
    Servers.ChangedLogs >> Dispatch.logs_ id


onProcessStarted : CId -> ProcessStarted.Data -> Dispatch
onProcessStarted id =
    Servers.StartedProcess >> Dispatch.processes_ id


onProcessConclusion : CId -> ProcessConclusion.Data -> Dispatch
onProcessConclusion id =
    Servers.ConcludedProcess >> Dispatch.processes_ id


onProcessesChanged : CId -> ProcessesChanged.Data -> Dispatch
onProcessesChanged id =
    Servers.ChangedProcesses >> Dispatch.processes_ id


onBruteforceFailed : CId -> BruteforceFailed.Data -> Dispatch
onBruteforceFailed id =
    Servers.FailedBruteforceProcess >> Dispatch.processes_ id
