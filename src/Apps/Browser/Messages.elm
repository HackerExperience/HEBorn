module Apps.Browser.Messages exposing (..)

import Game.Account.Finances.Models as Finances
import Game.Meta.Types.Network as Network exposing (NIP, IP)
import Game.Servers.Shared exposing (StorageId)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Requests.Browse as BrowseRequest
import Events.Account.Handlers.ServerPasswordAcquired as PasswordAcquired
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)
import Apps.Browser.Pages.Webserver.Messages as Webserver
import Apps.Browser.Pages.DownloadCenter.Messages as DownloadCenter
import Apps.Browser.Pages.Bank.Messages as Bank
import Apps.Browser.Models exposing (..)
import Apps.Browser.Shared exposing (..)


type Msg
    = -- Inside tab actions
      ActiveTabMsg TabMsg
    | SomeTabMsg Int TabMsg
    | EveryTabMsg TabMsg
      -- Browser actions
    | LaunchApp Params
    | ChangeTab Int
    | NewTab
    | NewTabIn String
    | DeleteTab Int
    | ReqDownload Network.NIP Filesystem.FileEntry StorageId
    | PublicDownload NIP Filesystem.FileEntry
    | HandlePasswordAcquired PasswordAcquired.Data
    | BankLogin Finances.AccountId String
    | BankLoginToken Finances.AccountId String
    | BankTransfer String IP Finances.AccountNumber Int
    | BankChangePass String
    | BankLogout String


type TabMsg
    = GoAddress String
    | UpdateAddress String
    | GoPrevious
    | GoNext
    | EnterModal (Maybe ModalAction)
    | Crack NIP
    | Cracked NIP String
    | AnyMap NIP
    | Login NIP String
    | HandleBankLogin String
    | HandleBankTransfer String
    | HandleLoginFailed
    | SelectEndpoint
    | NewApp DesktopApp
    | HandleBrowse BrowseRequest.Data
      -- site msgs
    | WebserverMsg Webserver.Msg
    | BankMsg Bank.Msg
    | DownloadCenterMsg DownloadCenter.Msg
