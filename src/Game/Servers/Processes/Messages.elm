module Game.Servers.Processes.Messages exposing (Msg(..))

import Events.Server.Handlers.ProcessCreated as ProcessCreated
import Events.Server.Handlers.ProcessCompleted as ProcessCompleted
import Events.Server.Handlers.ProcessBruteforceFailed as BruteforceFailed
import Events.Server.Handlers.ProcessesRecalcado as ProcessesRecalcado
import Game.Meta.Types.Network as Network
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Processes.Requests.Download as Download
import Game.Servers.Processes.Models exposing (..)


type Msg
    = DownloadRequestFailed ID
    | HandleStartDownload Network.NIP Download.StorageId Filesystem.FileEntry
    | HandleStartPublicDownload Network.NIP Download.StorageId Filesystem.FileEntry
    | BruteforceRequestFailed ID
    | HandleStartBruteforce Network.IP
    | HandleBruteforceFailed BruteforceFailed.Data
    | HandleProcessStarted ProcessCreated.Data
    | HandleProcessConclusion ProcessCompleted.Data
    | HandleProcessesChanged ProcessesRecalcado.Data
    | HandlePause ID
    | HandleResume ID
    | HandleRemove ID
