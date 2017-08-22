module Game.Storyline.Messages exposing (Msg(..))

import Game.Storyline.Missions.Messages as Missions


type Msg
    = Toggle
    | MissionsMsg Missions.Msg
