module Game.Storyline.Missions.Messages exposing (Msg(..))

import Game.Storyline.Missions.Actions exposing (Action)
import Game.Storyline.Missions.Models exposing (ID)
import Events.Account.Story.StepProceeded as StoryStepProceeded


type Msg
    = HandleActionDone Action
    | HandleStepProceeded StoryStepProceeded.Data
