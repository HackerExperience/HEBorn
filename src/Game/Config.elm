module Game.Config exposing (Config, serversConfig)

import Time exposing (Time)
import Core.Flags as Core
import Game.Servers.Config as Servers
import Game.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    }


serversConfig : Time -> Core.Flags -> Config msg -> Servers.Config msg
serversConfig lastTick flags config =
    { flags = flags
    , toMsg = ServersMsg >> config.toMsg
    , lastTick = lastTick
    }
