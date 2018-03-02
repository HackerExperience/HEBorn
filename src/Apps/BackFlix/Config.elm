module Apps.BackFlix.Config exposing (..)

import Game.BackFlix.Models as BackFlix
import Apps.BackFlix.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , logs : BackFlix.Model
    }
