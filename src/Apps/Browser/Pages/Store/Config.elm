module Apps.Browser.Pages.Store.Config exposing (Config)

import Apps.Browser.Pages.Store.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , onPurchase : msg
    }
