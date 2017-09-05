module Game.Storyline.Missions.Messages exposing (Msg(..))

import Game.Storyline.Missions.Actions exposing (Action)


type Msg
    = ActionDone Action
    | StepDone ( String, String ) String
