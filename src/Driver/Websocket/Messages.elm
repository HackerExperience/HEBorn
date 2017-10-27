module Driver.Websocket.Messages exposing (Msg(..))

import Events.Events as Events
import Driver.Websocket.Channels exposing (..)
import Json.Encode exposing (Value)


type Msg
    = Connected String
    | Disconnected
    | Joined Channel Value
    | JoinFailed Channel Value
    | Leaved Channel Value
    | Event Channel Value
    | HandleJoin Channel (Maybe Value)
    | HandleLeave Channel
