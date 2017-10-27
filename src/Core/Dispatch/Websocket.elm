module Core.Dispatch.Websocket exposing (..)

import Driver.Websocket.Channels exposing (Channel)
import Json.Encode exposing (Value)
import Events.Events as Events


{-| Messages related to the websocket driver.
-}
type Dispatch
    = Join Channel (Maybe Value)
    | Leave Channel
    | Connected String
    | Disconnected
    | Joined Channel Value
    | JoinFailed Channel Value
    | Leaved Channel (Maybe Value)
    | Event Channel Events.Event
