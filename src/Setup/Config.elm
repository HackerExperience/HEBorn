module Setup.Config exposing (..)

import Core.Flags as Core
import Game.Servers.Shared exposing (CId)
import Setup.Messages exposing (..)
import Setup.Pages.PickLocation.Config as PickLocation
import Setup.Pages.Mainframe.Config as Mainframe


type alias Config msg =
    { toMsg : Msg -> msg
    , accountId : String
    , mainframe : Maybe CId
    , flags : Core.Flags
    }


welcomeConfig : Config msg -> { onNext : msg }
welcomeConfig { toMsg } =
    { onNext = NextPage [] |> toMsg
    }


finishConfig : Config msg -> { onNext : msg, onPrevious : msg }
finishConfig { toMsg } =
    { onNext = NextPage [] |> toMsg
    , onPrevious = PreviousPage |> toMsg
    }


pickLocationConfig : Config msg -> PickLocation.Config msg
pickLocationConfig { toMsg } =
    { onNext = NextPage >> toMsg
    , onPrevious = PreviousPage |> toMsg
    , toMsg = PickLocationMsg >> toMsg
    }


mainframeConfig : Config msg -> Mainframe.Config msg
mainframeConfig { toMsg, flags, mainframe } =
    { onNext = NextPage >> toMsg
    , onPrevious = PreviousPage |> toMsg
    , toMsg = MainframeMsg >> toMsg
    , flags = flags
    , mainframe = mainframe
    }
