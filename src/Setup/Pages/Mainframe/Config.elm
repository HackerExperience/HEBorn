module Setup.Pages.Mainframe.Config exposing (Config)

import Setup.Settings as Settings exposing (Settings)
import Setup.Pages.Mainframe.Messages exposing (..)


type alias Config msg =
    { onNext : List Settings -> msg
    , onPrevious : msg
    , toMsg : Msg -> msg
    }
