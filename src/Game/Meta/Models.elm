module Game.Meta.Models exposing (..)

import Time exposing (Time)


type alias MetaModel =
    { online : Int
    , lastTick : Time
    }


initialMetaModel : MetaModel
initialMetaModel =
    { online = 0
    , lastTick = 0
    }
