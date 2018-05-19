module Setup.Config exposing (..)

import Core.Flags as Core
import Core.Error as Core
import Game.Servers.Shared exposing (CId)
import Setup.Messages exposing (..)
import Setup.Pages.PickLocation.Config as PickLocation
import Setup.Pages.Mainframe.Config as Mainframe


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , accountId : String
    , flags : Core.Flags
    , onError : Core.Error -> msg
    , onPlay : msg
    , onServerSetName : CId -> String -> msg

    -- TODO: remove, we're already receiving it using events
    , mainframe : Maybe CId
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
pickLocationConfig { toMsg, batchMsg } =
    { onNext = NextPage >> toMsg
    , onPrevious = PreviousPage |> toMsg
    , toMsg = PickLocationMsg >> toMsg
    , batchMsg = batchMsg
    }


mainframeConfig : Config msg -> Mainframe.Config msg
mainframeConfig config =
    { onNext = NextPage >> config.toMsg
    , onPrevious = PreviousPage |> config.toMsg
    , toMsg = MainframeMsg >> config.toMsg
    , batchMsg = config.batchMsg
    , flags = config.flags
    , onServerSetName = config.onServerSetName
    , mainframe = config.mainframe
    }
