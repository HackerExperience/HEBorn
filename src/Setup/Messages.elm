module Setup.Messages exposing (..)

import Json.Encode exposing (Value)
import Game.Servers.Shared as Servers
import Setup.Settings exposing (Settings, SettingTopic)
import Setup.Requests.SetServer as SetServerRequest
import Setup.Requests.Setup as SetupRequest
import Setup.Pages.PickLocation.Messages as PickLocation
import Setup.Pages.Mainframe.Messages as Mainframe


type Msg
    = NextPage (List Settings)
    | PreviousPage
    | MainframeMsg Mainframe.Msg
    | PickLocationMsg PickLocation.Msg
    | HandleJoinedAccount Value
    | HandleJoinedServer Servers.CId
    | SetServerRequest SetServerRequest.Data
    | SetupRequest SetupRequest.Data
