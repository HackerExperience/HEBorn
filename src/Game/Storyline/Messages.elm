module Game.Storyline.Messages exposing (Msg(..))

import Game.Storyline.Missions.Messages as Missions
import Events.Events as Events


type Msg
    = Toggle
    | MissionsMsg Missions.Msg
    | Event Events.Event
