module Apps.Browser.Messages exposing (..)

import Game.Web.Types exposing (Response)
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Shared exposing (StorageId)
import Game.Servers.Filesystem.Models as Filesystem
import Events.Account.PasswordAcquired as PasswordAcquired
import Apps.Apps as Apps
import Apps.Browser.Pages.Webserver.Messages as Webserver
import Apps.Browser.Pages.DownloadCenter.Messages as DownloadCenter
import Apps.Browser.Pages.Bank.Messages as Bank
import Apps.Browser.Menu.Messages as Menu
import Apps.Browser.Models exposing (..)


type Msg
    = MenuMsg Menu.Msg
      -- Inside tab actions
    | ActiveTabMsg TabMsg
    | SomeTabMsg Int TabMsg
    | EveryTabMsg TabMsg
      -- Browser actions
    | ChangeTab Int
    | NewTabIn String
    | ReqDownload Network.NIP Filesystem.FileEntry StorageId
    | PublicDownload NIP Filesystem.FileEntry
    | HandlePasswordAcquired PasswordAcquired.Data
    | ReqBankLogin Game.Data Network.NIP AccountNumber String
    | ReqBankTransfer Game.Data Network.NIP AccountNumber Network.NIP AccountNumber String Int
    | ReqBankLogout


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
    | Logout
    | LoginFailed
    | SelectEndpoint
    | OpenApp Apps.App
    | HandleFetched Response
      -- site msgs
    | WebserverMsg Webserver.Msg
    | BankMsg Bank.Msg
    | DownloadCenterMsg DownloadCenter.Msg
