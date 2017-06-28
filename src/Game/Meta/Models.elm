module Game.Meta.Models
    exposing
        ( Model
        , ActiveSession(..)
        , initialModel
        )

import Time exposing (Time)


type ActiveSession
    = Gateway
    | Endpoint


type alias Model =
    { online : Int
    , lastTick : Time
    , session : ActiveSession
    }


initialModel : Model
initialModel =
    { online = 0
    , lastTick = 0
    , session = Gateway
    }
