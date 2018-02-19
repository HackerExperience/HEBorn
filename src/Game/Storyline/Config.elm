module Game.Storyline.Config exposing (..)

import Core.Flags as Core
import Game.Storyline.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , flags : Core.Flags
    , accountId : String
    }
