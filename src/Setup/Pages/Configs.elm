module Setup.Pages.Configs exposing (..)

import Setup.Messages exposing (..)
import Game.Servers.Settings.Types exposing (Settings)
import Setup.Pages.PickLocation.Config as PickLocation
import Setup.Pages.Mainframe.Config as Mainframe


welcome : { onNext : List Settings -> Msg }
welcome =
    { onNext = NextPage }


finish : { onPrevious : Msg, onNext : List Settings -> Msg }
finish =
    { onNext = NextPage, onPrevious = PreviousPage }


pickLocation : PickLocation.Config Msg
pickLocation =
    { onNext = NextPage
    , onPrevious = PreviousPage
    , toMsg = PickLocationMsg
    }


setMainframeName : Mainframe.Config Msg
setMainframeName =
    { onNext = NextPage
    , onPrevious = PreviousPage
    , toMsg = MainframeMsg
    }
