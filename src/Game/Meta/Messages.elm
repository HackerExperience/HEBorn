module Game.Meta.Messages exposing (Msg(..))

import Time exposing (Time)


type Msg
    = Tick Time
    | Focused (Maybe ( String, String ))
