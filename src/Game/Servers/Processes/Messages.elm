module Game.Servers.Processes.Messages exposing (Msg(..))

import Events.Server.Processes.Started as ProcessStarted
import Events.Server.Processes.Conclusion as ProcessConclusion
import Events.Server.Processes.BruteforceFailed as BruteforceFailed
import Events.Server.Processes.Changed as ProcessesChanged
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
    | HandleProcessStarted ProcessStarted.Data
    | HandleProcessConclusion ProcessConclusion.Data
    | HandleProcessesChanged ProcessesChanged.Data
    | HandlePause ID
    | HandleResume ID
    | HandleRemove ID
    | HandleComplete ID -- may be removed
      -- to be deprecated
    | Start Type Network.IP ( Maybe FileID, Maybe Version, FileName )
