module Core.Dispatch.Websocket exposing (..)

import Driver.Websocket.Channels exposing (Channel)
import Json.Encode exposing (Value)


{-| Messages related to the websocket driver.
-}
type Dispatch
    = Connected String
    | Disconnected
    | Join Channel (Maybe Value)
    | Joined Channel Value
    | JoinFailed Channel Value
    | Leave Channel
    | Leaved Channel (Maybe Value)
