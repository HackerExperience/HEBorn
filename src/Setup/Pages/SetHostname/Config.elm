module Setup.Pages.SetHostname.Config exposing (Config)

import Setup.Pages.SetHostname.Messages exposing (..)


type alias Config msg =
    { onNext : msg
    , onPrevious : msg
    , toMsg : Msg -> msg
    }
