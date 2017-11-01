module Core.Dispatch.Servers exposing (..)

import Game.Account.Bounces.Models as Bounces
import Game.Servers.Shared exposing (CId)
import Game.Servers.Logs.Models as Logs
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Processes.Models as Processes
import Game.Network.Types as Network
import Events.Server.Filesystem.NewFile as NewFile
import Events.Server.Logs.Changed as LogsChanged
import Events.Server.Processes.Started as ProcessStarted
import Events.Server.Processes.Conclusion as ProcessConclusion
import Events.Server.Processes.BruteforceFailed as BruteforceFailed
import Events.Server.Processes.Changed as ProcessesChanged


{-| Messages related to servers.
-}
type Dispatch
    = Server CId Server


{-| Messages related to a specific server.
-}
type Server
    = SetBounce (Maybe Bounces.ID)
    | SetEndpoint (Maybe CId)
    | LoginServer
    | LogoutServer
    | FetchUrl
    | FetchedUrl
    | Filesystem Filesystem
    | Logs Logs
    | Processes Processes


{-| Messages related to server's filesystem.
-}
type Filesystem
    = DeleteFile Filesystem.FileID
    | MoveFile Filesystem.FileID Filesystem.Location
    | RenameFile Filesystem.FileID String
    | NewTextFile Filesystem.FilePath
    | NewDir Filesystem.FilePath
    | CreatedFile NewFile.Data


{-| Messages related to server's logs.
-}
type Logs
    = UpdateLog Logs.ID String
    | EncryptLog Logs.ID
    | DecryptLog Logs.ID
    | HideLog Logs.ID
    | DeleteLog Logs.ID
    | ChangedLogs LogsChanged.Data


{-| Messages related to server's processes.
-}
type Processes
    = PauseProcess Processes.ID
    | ResumeProcess Processes.ID
    | RemoveProcess Processes.ID
    | CompleteProcess Processes.ID
    | NewBruteforceProcess Network.IP
    | NewDownloadProcess Network.NIP Filesystem.ForeignFileBox String
    | NewPublicDownloadProcess Network.NIP Filesystem.ForeignFileBox String
    | StartedProcess ProcessStarted.Data
    | ConcludedProcess ProcessConclusion.Data
    | ChangedProcesses ProcessesChanged.Data
    | FailedBruteforceProcess BruteforceFailed.Data
