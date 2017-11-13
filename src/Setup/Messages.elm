module Setup.Messages exposing (..)

import Json.Encode exposing (Value)
import Requests.Types exposing (ResponseType)
import Setup.Types exposing (..)
import Game.Servers.Settings.Types exposing (Settings)
import Setup.Pages.PickLocation.Messages as PickLocation
import Setup.Pages.Mainframe.Messages as Mainframe


type Msg
    = NextPage (List Settings)
    | PreviousPage
    | MainframeMsg Mainframe.Msg
    | PickLocationMsg PickLocation.Msg
    | Request RequestMsg
    | HandleJoinedAccount Value


type RequestMsg
    = SetupRequest ResponseType
