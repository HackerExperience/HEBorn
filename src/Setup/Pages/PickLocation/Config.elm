module Setup.Pages.PickLocation.Config exposing (Config)

import Game.Servers.Settings.Types exposing (Settings)
import Setup.Pages.PickLocation.Messages exposing (..)


type alias Config msg =
    { onNext : List Settings -> msg
    , onPrevious : msg
    , toMsg : Msg -> msg
    }
