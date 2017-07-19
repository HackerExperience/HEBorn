module Game.Meta.Messages exposing (Msg(..), Context(..))

import Time exposing (Time)
import Events.Events as Events
import Game.Servers.Shared as Servers
import Game.Network.Types exposing (NIP)


type Context
    = Gateway
    | Endpoint


type Msg
    = SetGateway Servers.ID
    | SetEndpoint (Maybe NIP)
    | ContextTo Context
    | Event Events.Response
    | Tick Time
