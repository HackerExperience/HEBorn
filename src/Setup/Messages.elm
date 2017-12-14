module Setup.Messages exposing (..)

import Json.Encode exposing (Value)
import Requests.Types exposing (ResponseType)
import Game.Servers.Shared as Servers
import Setup.Settings exposing (Settings, SettingTopic)
import Setup.Pages.PickLocation.Messages as PickLocation
import Setup.Pages.Mainframe.Messages as Mainframe


type Msg
    = NextPage (List Settings)
    | PreviousPage
    | MainframeMsg Mainframe.Msg
    | PickLocationMsg PickLocation.Msg
    | HandleJoinedAccount Value
    | HandleJoinedServer Servers.CId
    | Request RequestMsg


type RequestMsg
    = SetServerRequest (List Settings) ResponseType
    | SetupRequest ResponseType
