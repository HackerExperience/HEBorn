module Game.Meta.Messages exposing (Msg(..), Context(..))

import Time exposing (Time)
import Events.Events as Events
import Game.Servers.Shared as Servers


type Context
    = Gateway
    | Endpoint


type Msg
    = SetGateway Servers.ID
    | ContextTo Context
    | Event Events.Response
    | Tick Time
