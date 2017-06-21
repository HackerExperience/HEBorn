module Game.Meta.Messages exposing (Msg(..))

import Events.Events as Events
import Time exposing (Time)


type Msg
    = Event Events.Response
    | Tick Time
