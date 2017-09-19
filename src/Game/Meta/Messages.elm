module Game.Meta.Messages exposing (Msg(..))

import Time exposing (Time)
import Events.Events as Events
import Game.Servers.Shared as Servers
import Game.Meta.Types exposing (..)


type Msg
    = Event Events.Event
    | Tick Time
