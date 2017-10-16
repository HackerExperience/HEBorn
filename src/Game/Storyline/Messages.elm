module Game.Storyline.Messages exposing (Msg(..))

import Game.Storyline.Missions.Messages as Missions
import Game.Storyline.Emails.Messages as Emails
import Events.Account.Story.NewEmail as StoryNewEmail
import Events.Account.Story.StepProceeded as StoryStepProceeded


type Msg
    = Toggle
    | MissionsMsg Missions.Msg
    | EmailsMsg Emails.Msg
