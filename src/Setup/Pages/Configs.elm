module Setup.Pages.Configs exposing (..)

import Setup.Messages exposing (..)
import Setup.Pages.PickLocation.Config as PickLocation
import Setup.Pages.SetHostname.Config as SetHostname


pickLocation : PickLocation.Config Msg
pickLocation =
    { onNext = NextPage
    , onPrevious = PreviousPage
    , toMsg = PickLocationMsg
    }


setHostname : SetHostname.Config Msg
setHostname =
    { onNext = NextPage
    , onPrevious = PreviousPage
    , toMsg = SetHostnameMsg
    }
