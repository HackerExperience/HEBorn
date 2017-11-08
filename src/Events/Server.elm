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

        "process_created" ->
            ProcessStarted.handler (onProcessStarted cid) json

        "process_conclusion" ->
            ProcessConclusion.handler (onProcessConclusion cid) json

        "top_recalcado" ->
            ProcessesChanged.handler (onProcessesChanged cid) json

        "bruteforce_failed" ->
            BruteforceFailed.handler (onBruteforceFailed cid) json

        _ ->
            Err ""



-- internals


onNewFile : CId -> NewFile.Data -> Dispatch
onNewFile id =
    Servers.CreatedFile >> Dispatch.filesystem id


onProcessStarted : CId -> ProcessStarted.Data -> Dispatch
onProcessStarted id =
    Servers.StartedProcess >> Dispatch.processes id


onProcessConclusion : CId -> ProcessConclusion.Data -> Dispatch
onProcessConclusion id =
    Servers.ConcludedProcess >> Dispatch.processes id


onProcessesChanged : CId -> ProcessesChanged.Data -> Dispatch
onProcessesChanged id =
    Servers.ChangedProcesses >> Dispatch.processes id


onBruteforceFailed : CId -> BruteforceFailed.Data -> Dispatch
onBruteforceFailed id =
    Servers.FailedBruteforceProcess >> Dispatch.processes id
