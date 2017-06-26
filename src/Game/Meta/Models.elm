module Game.Meta.Models exposing (..)

import Time exposing (Time)


type alias Model =
    { online : Int
    , lastTick : Time
    }


initialModel : Model
initialModel =
    { online = 0
    , lastTick = 0
    }
