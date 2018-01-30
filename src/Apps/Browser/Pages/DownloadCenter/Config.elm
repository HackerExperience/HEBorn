module Apps.Browser.Pages.DownloadCenter.Config exposing (Config)

import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)
import Apps.Browser.Pages.DownloadCenter.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , onLogin : NIP -> String -> msg
    , onLogout : NIP -> msg
    , onCrack : NIP -> msg
    , onAnyMap : NIP -> msg
    , onPublicDownload : NIP -> Filesystem.FileEntry -> msg
    , onSelectEndpoint : msg
    , onNewApp : DesktopApp -> msg
    , endpoints : List CId
    }
