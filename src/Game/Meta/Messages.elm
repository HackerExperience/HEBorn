module Game.Meta.Messages exposing (Msg(..))

import Time exposing (Time)
import Events.Events as Events
import Game.Servers.Shared as Servers
import Game.Network.Types exposing (NIP)
import Game.Meta.Types exposing (..)


type Msg
    = SetGateway Servers.ID
    | SetEndpoint (Maybe NIP)
    | ContextTo Context
    | Event Events.Event
    | Tick Time
