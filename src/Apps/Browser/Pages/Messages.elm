module Apps.Browser.Pages.Messages exposing (Msg(..))

import Apps.Browser.Pages.CommonActions exposing (..)
import Apps.Browser.Pages.NoWebserver.Messages as NoWebserver


type Msg
    = NoWebserverMsg NoWebserver.Msg
    | GlobalMsg CommonActions
    | Ignore
