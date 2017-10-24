module Apps.Browser.Pages.CommonActions exposing (CommonActions(..))

import Game.Servers.Shared as Servers
import Game.Network.Types exposing (NIP)
import Game.Servers.Filesystem.Shared exposing (ForeignFileBox)
import Apps.Apps as Apps


type CommonActions
    = GoAddress String
    | NewTabIn String
    | Crack NIP
    | AnyMap NIP
    | Login NIP String
    | Cracked NIP String
    | PublicDownload NIP ForeignFileBox
    | LoginFailed
    | OpenApp Apps.App
    | SelectEndpoint
    | Logout
