module Driver.Websocket.Messages exposing (Msg(..))

import Events.Events as Events
import Driver.Websocket.Channels exposing (..)
import Json.Encode exposing (Value)


type Msg
    = JoinChannel Channel (Maybe String) (Maybe Value)
    | NewEvent Channel (Maybe String) Value
    | Broadcast Events.Event
