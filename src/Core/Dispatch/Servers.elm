module Core.Dispatch.Servers exposing (..)

import Game.Servers.Shared exposing (CId)
import Events.Server.Filesystem.NewFile as NewFile
import Events.Server.Logs.Changed as LogsChanged
import Events.Server.Processes.Started as ProcessStarted
import Events.Server.Processes.Conclusion as ProcessConclusion
import Events.Server.Processes.BruteforceFailed as BruteforceFailed
import Events.Server.Processes.Changed as ProcessesChanged


{-| Messages related to servers.
-}
type Dispatch
    = SetEndpoint
    | SetBounce
    | Server CId Server


{-| Messages related to a specific server.
-}
type Server
    = LoginServer
    | LogoutServer
    | FetchUrl
    | FetchedUrl
    | Filesystem Filesystem
    | Logs Logs
    | Processes Processes


{-| Messages related to server's filesystem.
-}
type Filesystem
    = DeleteFile
    | RenameFile
    | NewFile
    | NewDir
    | CreatedNewFile NewFile.Data


{-| Messages related to server's logs.
-}
type Logs
    = UpdateLog
    | EncryptLog
    | HideLog
    | DeleteLog
    | ChangedLogs LogsChanged.Data


{-| Messages related to server's processes.
-}
type Processes
    = PauseProcess
    | ResumeProcess
    | RemoveProcess
    | CompleteProcess
    | NewBruteforceProcess
    | NewDownloadProcess
    | NewPublicDownloadProcess
    | StartedProcess ProcessStarted.Data
    | ConcludedProcess ProcessConclusion.Data
    | ChangedProcesses ProcessesChanged.Data
    | FailedBruteforceProcess BruteforceFailed.Data
