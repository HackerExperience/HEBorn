module Game.Servers.Tunnels.Messages exposing (Msg(..))

import Events.Events as Events
import Requests.Types exposing (ResponseType)


type Msg
    = Request RequestMsg
    | Event Events.Event


type RequestMsg
    = RequestMsg
