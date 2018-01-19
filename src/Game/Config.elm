module Game.Config exposing (..)

import Time exposing (Time)
import Core.Flags as Core
import Game.Account.Config as Account
import Game.Servers.Config as Servers
import Game.Account.Models as Account
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


accountConfig :
    ((Bool -> Account.Model) -> Account.Model)
    -> Time
    -> Core.Flags
    -> Config msg
    -> Account.Config msg
accountConfig fallToGateway lastTick flags config =
    { flags = flags
    , toMsg = AccountMsg >> config.toMsg
    , lastTick = lastTick
    , fallToGateway = fallToGateway
    }
