module Game.BackFlix.Config exposing (Config)

import Game.BackFlix.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    }
