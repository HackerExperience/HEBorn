module Driver.Websocket.Messages exposing (Msg(..))

import Events.Events as Events
import Driver.Websocket.Channels exposing (..)
import Json.Encode exposing (Value)


type Msg
    = JoinChannel Channel (Maybe String)
    | NewEvent Events.Event Value
    | Broadcast Events.Response
