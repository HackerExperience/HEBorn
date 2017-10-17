module Apps.Browser.Pages.DownloadCenter.Messages exposing (Msg(..))

import Apps.Browser.Pages.CommonActions exposing (..)
import Game.Network.Types exposing (NIP)
import Apps.Apps as Apps


type Msg
    = GlobalMsg CommonActions
    | UpdatePasswordField String
    | SetShowingPanel Bool
    | StartDownload NIP String
