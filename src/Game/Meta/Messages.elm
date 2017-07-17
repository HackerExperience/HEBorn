module Game.Meta.Messages exposing (Msg(..), Context(..))

import Time exposing (Time)
import Events.Events as Events
import Game.Servers.Shared as Servers
import Game.Network.Types as Network


type Context
    = Gateway
    | Endpoint


type Msg
    = SetGateway Servers.ID
    | SetEndpoint (Maybe Network.IP)
    | ContextTo Context
    | Event Events.Response
    | Tick Time
