module Apps.Browser.Menu.Config exposing (..)

import Apps.Browser.Menu.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg }
