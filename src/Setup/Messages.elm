module Setup.Messages exposing (..)

import Json.Encode exposing (Value)
import Requests.Types exposing (ResponseType)
import Setup.Types exposing (..)
import Setup.Pages.PickLocation.Messages as PickLocation
import Setup.Pages.SetHostname.Messages as SetHostname


type Msg
    = NextPage
    | PreviousPage
    | SetHostnameMsg SetHostname.Msg
    | PickLocationMsg PickLocation.Msg
    | Request RequestMsg
    | HandleJoinedAccount Value


type RequestMsg
    = SetupRequest ResponseType
