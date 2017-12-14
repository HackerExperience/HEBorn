module Setup.Pages.Configs exposing (..)

import Setup.Messages exposing (..)
import Setup.Pages.PickLocation.Config as PickLocation
import Setup.Pages.Mainframe.Config as Mainframe


welcome : { onNext : Msg }
welcome =
    { onNext = NextPage [] }


finish : { onNext : Msg, onPrevious : Msg }
finish =
    { onNext = NextPage [], onPrevious = PreviousPage }


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
