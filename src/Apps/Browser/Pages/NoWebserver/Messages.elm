module Apps.Browser.Pages.NoWebserver.Messages exposing (Msg(..))

import Apps.Browser.Pages.CommonActions exposing (..)


type Msg
    = GlobalMsg CommonActions
    | UpdatePasswordField String
    | SetShowingPanel Bool
