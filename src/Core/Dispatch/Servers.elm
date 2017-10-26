module Core.Dispatch.Servers exposing (..)

{-| Messages related to servers.
-}


type Dispatch
    = SetEndpoint
    | SetBounce
    | Server Server


{-| Messages related to a specific server.
-}
type Server
    = LoginServer
    | LogoutServer
    | FetchUrl
    | FetchedUrl
    | Filesystem Filesystem
    | Logs Logs
    | Procesess Procesess


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
type Procesess
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
