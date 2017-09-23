module Driver.Websocket.Messages exposing (Msg(..))

import Events.Events as Events
import Driver.Websocket.Channels exposing (..)
import Json.Encode exposing (Value)


type Msg
    = JoinChannel Channel (Maybe String) (Maybe Value)
    | LeaveChannel Channel (Maybe String)
    | NewEvent Channel (Maybe String) Value
    | Broadcast Events.Event
