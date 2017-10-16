module Apps.Browser.Pages.DownloadCenter.Messages exposing (Msg(..))

import Apps.Browser.Pages.CommonActions exposing (..)
import Game.Network.Types exposing (NIP)


type Msg
    = GlobalMsg CommonActions
    | UpdatePasswordField String
    | SetShowingPanel Bool
    | ReqDownload NIP String
