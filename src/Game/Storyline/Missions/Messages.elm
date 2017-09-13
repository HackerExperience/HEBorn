module Game.Storyline.Missions.Messages exposing (Msg(..))

import Game.Storyline.Missions.Actions exposing (Action)
import Game.Storyline.Missions.Models exposing (ID)


type Msg
    = ActionDone Action
    | StepDone ( ID, ID ) ID
