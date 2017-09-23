module Apps.Browser.Pages.Bank.Messages exposing (Msg(..))

import Apps.Browser.Pages.CommonActions exposing (..)


type Msg
    = GlobalMsg CommonActions
    | UpdatePasswordField String
