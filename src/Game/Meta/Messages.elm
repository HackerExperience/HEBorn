module Game.Meta.Messages exposing (Msg(..))

import Time exposing (Time)
import Events.Events as Events
import Game.Servers.Shared as Servers


type Msg
    = SetGateway Servers.ID
    | Event Events.Response
    | Tick Time
