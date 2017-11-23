module Apps.Browser.Messages exposing (..)

import Game.Web.Types exposing (Response)
import Game.Meta.Types.Network as Network
import Game.Servers.Filesystem.Models as Filesystem
import Apps.Apps as Apps
import Apps.Browser.Menu.Messages as Menu
import Apps.Browser.Pages.Messages as Page
import Events.Account.PasswordAcquired as PasswordAcquired


type Msg
    = MenuMsg Menu.Msg
      -- Inside tab actions
    | ActiveTabMsg TabMsg
    | SomeTabMsg Int TabMsg
    | EveryTabMsg TabMsg
      -- Browser actions
    | NewTabIn String
    | ChangeTab Int
    | OpenApp Apps.App
    | SelectEndpoint
    | Logout
    | PublicDownload Network.NIP Filesystem.FileEntry
    | HandlePasswordAcquired PasswordAcquired.Data


type TabMsg
    = UpdateAddress String
    | GoAddress String
    | GoPrevious
    | GoNext
    | PageMsg Page.Msg
    | Crack Network.NIP
    | AnyMap Network.NIP
    | Login Network.NIP String
    | Cracked Network.NIP String
    | LoginFailed
    | HandleFetched Response
