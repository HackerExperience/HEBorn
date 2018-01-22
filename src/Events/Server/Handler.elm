module Events.Server.Handler exposing (events)

import Events.Shared exposing (Router)
import Game.Servers.Shared as Servers exposing (CId)
import Events.Server.Handlers.FileAdded as FileAdded
import Events.Server.Handlers.FileDownloaded as FileDownloaded
import Events.Server.Handlers.ProcessCreated as ProcessCreated
import Events.Server.Handlers.ProcessCompleted as ProcessCompleted
import Events.Server.Handlers.ProcessesRecalcado as ProcessesRecalcado
import Events.Server.Handlers.ProcessBruteforceFailed as ProcessBruteforceFailed
import Events.Server.Handlers.LogCreated as LogCreated
import Events.Server.Handlers.MotherboardUpdated as MotherboardUpdated
import Events.Server.Config exposing (..)


events : Config msg -> CId -> Router msg
events config cid name value =
    case name of
        "file_added" ->
            FileAdded.handler (config.onFileAdded cid) value

        "file_downloaded" ->
            FileDownloaded.handler (config.onFileDownloaded cid) value

        "process_created" ->
            ProcessCreated.handler (config.onProcessCreated cid) value

        "process_completed" ->
            ProcessCompleted.handler (config.onProcessCompleted cid) value

        "top_recalcado" ->
            ProcessesRecalcado.handler (config.onProcessesRecalcado cid) value

        "bruteforce_failed" ->
            ProcessBruteforceFailed.handler (config.onBruteforceFailed cid) value

        "log_created" ->
            LogCreated.handler (config.onLogCreated cid) value

        "motherboard_updated" ->
            MotherboardUpdated.handler (config.onMotherboardUpdated cid) value

        _ ->
            Err "Not implemented or incompatible event router"
