module Game.Meta.Models
    exposing
        ( Model
        , initialModel
        )

import Game.Servers.Shared as Servers
import Time exposing (Time)


type alias Model =
    { online : Int
    , lastTick : Time
    }



-- TODO: move active gateway / context to account


initialModel : Model
initialModel =
    { online = 0
    , lastTick = 0
    }
