module Setup.Pages.PickLocation.Config exposing (Config)

import Setup.Pages.PickLocation.Messages exposing (..)


type alias Config msg =
    { onNext : msg
    , onPrevious : msg
    , toMsg : Msg -> msg
    }
