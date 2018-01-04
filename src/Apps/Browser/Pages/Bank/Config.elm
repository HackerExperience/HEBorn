module Apps.Browser.Pages.Bank.Config exposing (Config)

import Apps.Browser.Pages.Bank.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    }
