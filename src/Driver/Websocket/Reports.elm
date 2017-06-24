module Driver.Websocket.Reports exposing (..)

import Driver.Websocket.Channels exposing (..)


type Report
    = Connected String String
    | Disconnected
    | Joined Channel
