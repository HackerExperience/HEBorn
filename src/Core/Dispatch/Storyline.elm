module Core.Dispatch.Storyline exposing (..)

import Events.Account.Story.StepProceeded as StoryStepProceeded
import Events.Account.Story.NewEmail as StoryNewEmail
import Events.Account.Story.ReplyUnlocked as StoryReplyUnlocked


type Dispatch
    = Emails Emails
    | Missions Missions


type Emails
    = ReceivedEmail StoryNewEmail.Data
    | UnlockedEmail StoryReplyUnlocked.Data


type Missions
    = ProceedMission
    | ProceededMission StoryStepProceeded.Data
