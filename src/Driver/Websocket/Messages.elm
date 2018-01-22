module Driver.Websocket.Messages exposing (..)

import Driver.Websocket.Channels exposing (..)
import Json.Decode exposing (Value)


type alias Token =
    String


type alias ClientName =
    String


type Msg
    = Connected Token ClientName
    | Disconnected
    | Joined Channel Value
    | JoinFailed Channel Value
    | Leaved Channel Value
    | HandleJoin Channel (Maybe Value)
    | HandleLeave Channel
