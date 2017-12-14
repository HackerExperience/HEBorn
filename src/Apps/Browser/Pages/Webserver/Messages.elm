module Apps.Browser.Pages.Webserver.Messages exposing (Msg(..))

import Apps.Browser.Pages.CommonActions exposing (..)


type Msg
    = GlobalMsg CommonActions
    | UpdatePasswordField String
    | SetShowingPanel Bool
