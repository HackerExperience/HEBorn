module Core.Dispatch.Storyline exposing (..)

import Game.Storyline.Emails.Contents as Emails
import Game.Storyline.Missions.Actions as Missions


type Dispatch
    = Toggle
    | Emails Emails
    | Missions Missions


type Emails
    = ReplyEmail Emails.Content


type Missions
    = ActionDone Missions.Action
    | ProceedMission
