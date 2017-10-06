module Driver.Websocket.Reports exposing (..)

import Json.Decode exposing (Value)
import Driver.Websocket.Channels exposing (..)


type Report
    = Connected String
    | Disconnected
    | Joined Channel Value
    | JoinFailed Channel Value
