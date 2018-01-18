module Game.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Game.Account.Config as Account
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


accountConfig : Core.Flags -> Config msg -> Account.Config msg
accountConfig flags config =
    { flags = flags
    , toMsg = AccountMsg >> config.toMsg
    }
