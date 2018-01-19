module Game.Storyline.Missions.Config exposing (..)

import Game.Storyline.Missions.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    }
