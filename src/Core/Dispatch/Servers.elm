module Core.Dispatch.Servers exposing (..)

import Game.Servers.Shared exposing (CId)


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


{-| Messages related to server's logs.
-}
type Logs
    = UpdateLog
    | EncryptLog
    | HideLog
    | DeleteLog


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
    | StartedProcess
    | ConcludedProcess
    | ChangedProcess
    | FailedProcess
    | SuccessProcess
