module Events.Server.Config exposing (..)

import Game.Servers.Shared exposing (CId)
import Events.Server.Handlers.FileAdded as FileAdded
import Events.Server.Handlers.FileDownloaded as FileDownloaded
import Events.Server.Handlers.ProcessCreated as ProcessCreated
import Events.Server.Handlers.ProcessCompleted as ProcessCompleted
import Events.Server.Handlers.ProcessesRecalcado as ProcessesRecalcado
import Events.Server.Handlers.ProcessBruteforceFailed as ProcessBruteforceFailed
import Events.Server.Handlers.LogCreated as LogCreated
import Events.Server.Handlers.MotherboardUpdated as MotherboardUpdated


type alias Config msg =
    { onFileAdded : CId -> FileAdded.Data -> msg
    , onFileDownloaded : CId -> FileDownloaded.Data -> msg
    , onProcessCreated : CId -> ProcessCreated.Data -> msg
    , onProcessCompleted : CId -> ProcessCompleted.Data -> msg
    , onProcessesRecalcado : CId -> ProcessesRecalcado.Data -> msg
    , onBruteforceFailed : CId -> ProcessBruteforceFailed.Data -> msg
    , onLogCreated : CId -> LogCreated.Data -> msg
    , onMotherboardUpdated : CId -> MotherboardUpdated.Data -> msg
    }
