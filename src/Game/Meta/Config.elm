module Game.Meta.Config exposing (..)

import Game.Meta.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    }
