module Events.Server exposing (events)

import Events.Types exposing (Router)
import Core.Dispatch.Websocket exposing (..)
import Events.Server.Filesystem.NewFile as NewFile
import Events.Server.Logs.Changed as LogsChanged
import Events.Server.Processes.Started as ProcessStarted
import Events.Server.Processes.Conclusion as ProcessConclusion
import Events.Server.Processes.BruteforceFailed as BruteforceFailed
import Events.Server.Processes.Changed as ProcessesChanged


events : Router ServerEvent
events name json =
    case name of
        "new_file" ->
            NewFile.handler NewFile json

        "log_changed" ->
            LogsChanged.handler LogsChanged json

        "process_started" ->
            ProcessStarted.handler ProcessStarted json

        "process_conclusion" ->
            ProcessConclusion.handler ProcessConclusion json

        "processes_changed" ->
            ProcessesChanged.handler ProcessesChanged json

        "bruteforce_failed" ->
            BruteforceFailed.handler BruteforceFailed json

        _ ->
            Err ""
