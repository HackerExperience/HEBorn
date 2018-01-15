module Events.Server exposing (events)

import Events.Types exposing (Router)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Servers.Shared as Servers exposing (CId)
import Events.Server.Filesystem.Added as FileAdded
import Events.Server.Filesystem.Downloaded as FileDownloaded
import Events.Server.Logs.Created as LogCreated
import Events.Server.Processes.Started as ProcessStarted
import Events.Server.Processes.Conclusion as ProcessConclusion
import Events.Server.Processes.BruteforceFailed as BruteforceFailed
import Events.Server.Processes.Changed as ProcessesChanged
import Events.Server.Hardware.MotherboardUpdated as MotherboardUpdated


events : CId -> Router Dispatch
events cid name json =
    case name of
        "file_added" ->
            FileAdded.handler (uncurry <| onFileAdded cid) json

        "file_downloaded" ->
            FileDownloaded.handler (uncurry <| onFileDownloaded cid) json

        "process_created" ->
            ProcessStarted.handler (onProcessStarted cid) json

        "process_completed" ->
            ProcessConclusion.handler (onProcessConclusion cid) json

        "top_recalcado" ->
            ProcessesChanged.handler (onProcessesChanged cid) json

        "bruteforce_failed" ->
            BruteforceFailed.handler (onBruteforceFailed cid) json

        "log_created" ->
            LogCreated.handler (onLogCreated cid) json

        "motherboard_updated" ->
            MotherboardUpdated.handler (onMotherbardUpdated cid) json

        _ ->
            Err "Not implemented or incompatible event router"



-- internals


onFileAdded : CId -> Servers.StorageId -> FileAdded.Data -> Dispatch
onFileAdded cid id =
    Servers.FileAdded >> Dispatch.filesystem cid id


onFileDownloaded : CId -> Servers.StorageId -> FileDownloaded.Data -> Dispatch
onFileDownloaded cid id =
    Servers.FileDownloaded >> Dispatch.filesystem cid id


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


onLogCreated : CId -> LogCreated.Data -> Dispatch
onLogCreated id =
    Servers.CreatedLog >> Dispatch.logs id


onMotherbardUpdated : CId -> MotherboardUpdated.Data -> Dispatch
onMotherbardUpdated id =
    Servers.MotherboardUpdated >> Dispatch.hardware id
