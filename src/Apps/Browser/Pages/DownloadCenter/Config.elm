module Apps.Browser.Pages.DownloadCenter.Config exposing (Config)

import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Filesystem.Models as Filesystem
import Apps.Apps as Apps
import Apps.Browser.Pages.DownloadCenter.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , onLogin : NIP -> String -> msg
    , onLogout : msg
    , onCrack : NIP -> msg
    , onAnyMap : NIP -> msg
    , onPublicDownload : NIP -> Filesystem.FileEntry -> msg
    , onSelectEndpoint : msg
    , onNewApp : Apps.App -> msg
    }
