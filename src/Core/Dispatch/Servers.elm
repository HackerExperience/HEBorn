module Core.Dispatch.Servers exposing (..)

import Time exposing (Time)
import Game.Account.Bounces.Models as Bounces
import Game.Servers.Shared exposing (CId)
import Game.Servers.Logs.Models as Logs
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Processes.Models as Processes
import Game.Network.Types as Network
import Events.Server.Filesystem.Added as FileAdded
import Events.Server.Processes.Started as ProcessStarted
import Events.Server.Processes.Conclusion as ProcessConclusion
import Events.Server.Processes.BruteforceFailed as BruteforceFailed
import Events.Server.Processes.Changed as ProcessesChanged
import Game.Web.Models as Web
import Game.Web.Types as Web


{-| Messages related to servers.
-}
type Dispatch
    = Server CId Server
    | Login Network.NIP Network.IP String Web.Requester
    | FetchedUrl Web.Requester Web.Response
    | FailLogin Web.Requester


{-| Messages related to a specific server.
-}
type Server
    = SetBounce (Maybe Bounces.ID)
    | SetEndpoint (Maybe CId)
    | Filesystem Filesystem
    | Logs Logs
    | Processes Processes
    | LogoutServer
    | FetchUrl String Network.ID Web.Requester


{-| Messages related to server's filesystem.
-}
type Filesystem
    = DeleteFile Filesystem.Id
    | MoveFile Filesystem.Id Filesystem.Path
    | RenameFile Filesystem.Id String
    | NewTextFile Filesystem.Path Filesystem.Name
    | NewDir Filesystem.Path Filesystem.Name
    | FileAdded FileAdded.Data


{-| Messages related to server's logs.
-}
type Logs
    = UpdateLog Logs.ID String
    | EncryptLog Logs.ID
    | HideLog Logs.ID
    | DeleteLog Logs.ID


{-| Messages related to server's processes.
-}
type Processes
    = PauseProcess Processes.ID
    | ResumeProcess Processes.ID
    | RemoveProcess Processes.ID
    | CompleteProcess Processes.ID
    | NewBruteforceProcess Time Network.IP
    | NewDownloadProcess Time Network.NIP Filesystem.FileEntry String
    | NewPublicDownloadProcess Time Network.NIP Filesystem.FileEntry String
    | StartedProcess ProcessStarted.Data
    | ConcludedProcess ProcessConclusion.Data
    | ChangedProcesses ProcessesChanged.Data
    | FailedBruteforceProcess BruteforceFailed.Data
