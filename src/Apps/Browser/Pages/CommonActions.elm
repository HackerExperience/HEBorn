module Apps.Browser.Pages.CommonActions exposing (CommonActions(..))

import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Filesystem.Models as Filesystem
import Apps.Apps as Apps


type CommonActions
    = GoAddress String
    | NewTabIn String
    | Crack NIP
    | AnyMap NIP
    | Login NIP String
    | Cracked NIP String
    | PublicDownload NIP Filesystem.FileEntry
    | LoginFailed
    | OpenApp Apps.App
    | SelectEndpoint
    | Logout
