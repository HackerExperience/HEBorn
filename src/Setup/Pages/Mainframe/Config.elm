module Setup.Pages.Mainframe.Config exposing (Config)

import Setup.Pages.Mainframe.Messages exposing (..)


type alias Config msg =
    { onNext : msg
    , onPrevious : msg
    , toMsg : Msg -> msg
    }
