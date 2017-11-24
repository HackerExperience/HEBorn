module Game.Meta.Messages exposing (Msg(..))

import Time exposing (Time)
import Game.Servers.Shared as Servers
import Game.Meta.Types.Context exposing (..)


type Msg
    = Tick Time
