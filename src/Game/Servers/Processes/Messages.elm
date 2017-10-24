module Game.Servers.Processes.Messages exposing (Msg(..), RequestMsg(..))

import Requests.Types exposing (ResponseType)
import Game.Servers.Processes.Models exposing (..)
import Game.Network.Types as Network
import Game.Servers.Filesystem.Shared as Filesystem
import Events.Server.Processes.Started as ProcessStarted
import Events.Server.Processes.Conclusion as ProcessConclusion
import Events.Server.Processes.BruteforceFailed as BruteforceFailed
import Events.Server.Processes.Changed as ProcessesChanged


type Msg
    = Pause ID
    | Resume ID
    | Remove ID
    | Complete ID
    | StartBruteforce Network.IP
    | StartDownload Network.NIP Filesystem.ForeignFileBox String
    | StartPublicDownload Network.NIP Filesystem.ForeignFileBox String
      -- start may be removed if we provide a specific
      -- function for every process type
    | Start Type Network.IP ( Maybe FileID, Maybe Version, FileName )
    | Request RequestMsg
    | HandleProcessStarted ProcessStarted.Data
    | HandleProcessConclusion ProcessConclusion.Data
    | HandleBruteforceFailed BruteforceFailed.Data
    | HandleProcessesChanged ProcessesChanged.Data
    | HandleBruteforceSuccess ID


type RequestMsg
    = BruteforceRequest ID ResponseType
    | DownloadRequest ID ResponseType
