module Game.Web.Config exposing (..)

import Core.Flags as Core
import Game.Servers.Models as Servers
import Game.Web.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , flags : Core.Flags
    , servers : Servers.Model
    }
