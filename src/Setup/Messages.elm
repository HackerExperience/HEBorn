module Setup.Messages exposing (..)

import Json.Encode exposing (Value)
import Requests.Types exposing (ResponseType)
import Setup.Types exposing (..)
import Setup.Pages.PickLocation.Messages as PickLocation
import Setup.Pages.Mainframe.Messages as Mainframe


type Msg
    = NextPage
    | PreviousPage
    | MainframeMsg Mainframe.Msg
    | PickLocationMsg PickLocation.Msg
    | Request RequestMsg
    | HandleJoinedAccount Value


type RequestMsg
    = SetupRequest ResponseType
