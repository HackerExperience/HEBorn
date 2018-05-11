module Apps.Browser.Pages.DownloadCenter.Config exposing (Config)

import Game.Account.Database.Models exposing (HackedServers)
import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)
import Apps.Browser.Pages.DownloadCenter.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , endpoints : List CId
    , hackedServers : HackedServers
    , onLogin : NIP -> String -> msg
    , onLogout : NIP -> msg
    , onCrack : NIP -> msg
    , onAnyMap : NIP -> msg
    , onSetEndpoint : Maybe CId -> msg
    , onPublicDownload : NIP -> Filesystem.FileEntry -> msg
    , onSelectEndpoint : msg
    , onNewApp : DesktopApp -> msg
    }
