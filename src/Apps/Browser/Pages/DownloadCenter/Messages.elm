module Apps.Browser.Pages.DownloadCenter.Messages exposing (Msg(..))

import Apps.Browser.Pages.CommonActions exposing (..)
import Game.Meta.Types.Network exposing (NIP)


type Msg
    = GlobalMsg CommonActions
    | UpdatePasswordField String
    | SetShowingPanel Bool
