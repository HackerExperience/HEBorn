module Driver.Websocket.Reports exposing (..)

import Json.Decode exposing (Value)
import Driver.Websocket.Channels exposing (..)


type Report
    = Connected String
    | Disconnected
    | Joined Channel (Maybe String) Value
    | JoinFailed Channel (Maybe String) Value
