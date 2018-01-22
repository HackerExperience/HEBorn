module Core.Dispatch.Servers exposing (..)

import Game.Account.Bounces.Shared as Bounces
import Game.Account.Finances.Models as Finances
import Game.Account.Finances.Shared as Finances
import Game.Servers.Shared exposing (CId, StorageId)
import Game.Servers.Logs.Models as Logs
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Processes.Models as Processes
import Game.Meta.Types.Network as Network
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Apps.Browser.Pages.Bank.Models as Bank
import Game.Web.Models as Web
import Game.Web.Types as Web
import Game.Meta.Types.Requester exposing (Requester)


{-| Messages related to servers.
-}
type Dispatch
    = Server CId Server
    | Login Network.NIP Network.IP String Requester
    | FetchedUrl Requester Web.Response
    | FailLogin Requester


{-| Messages related to a specific server.
-}
type Server
    = SetBounce (Maybe Bounces.ID)
    | SetEndpoint (Maybe CId)
    | SetActiveNIP Network.NIP
    | Filesystem StorageId Filesystem
    | Logs Logs
    | Processes Processes
    | Hardware Hardware
    | LogoutServer
    | FetchUrl String Network.ID Requester
    | BankAccountLoginSuccessful Requester Finances.BankAccountData
    | BankAccountLoginError Requester
    | BankAccountTransferSuccessful Requester
    | BankAccountTransferError Requester


{-| Messages related to server's filesystem.
-}
type Filesystem
    = DeleteFile Filesystem.Id
    | MoveFile Filesystem.Id Filesystem.Path
    | RenameFile Filesystem.Id String
    | NewTextFile Filesystem.Path Filesystem.Name
    | NewDir Filesystem.Path Filesystem.Name


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
    | NewBruteforceProcess Network.IP
    | NewDownloadProcess Network.NIP StorageId Filesystem.FileEntry
    | NewPublicDownloadProcess Network.NIP StorageId Filesystem.FileEntry


type Hardware
    = MotherboardUpdate Motherboard
