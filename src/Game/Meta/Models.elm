module Game.Meta.Models
    exposing
        ( Model
        , initialModel
        , getLastTick
        )

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


getLastTick : Model -> Time
getLastTick =
    .lastTick
