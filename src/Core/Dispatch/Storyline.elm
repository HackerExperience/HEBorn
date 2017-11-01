module Core.Dispatch.Storyline exposing (..)

import Time exposing (Time)
import Events.Account.Story.StepProceeded as StoryStepProceeded
import Events.Account.Story.NewEmail as StoryNewEmail
import Events.Account.Story.ReplyUnlocked as StoryReplyUnlocked
import Game.Storyline.Emails.Contents as Emails
import Game.Storyline.Missions.Actions as Missions


type Dispatch
    = Toggle
    | Emails Emails
    | Missions Missions


type Emails
    = ReplyEmail Emails.Content
    | ReceivedEmail StoryNewEmail.Data
    | UnlockedEmail StoryReplyUnlocked.Data


type Missions
    = ActionDone Missions.Action
    | ProceedMission
    | ProceededMission StoryStepProceeded.Data
