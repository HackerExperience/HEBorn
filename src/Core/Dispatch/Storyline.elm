module Core.Dispatch.Storyline exposing (..)


type Dispatch
    = Emails Emails
    | Missions Missions


type Emails
    = ReceivedEmail
    | UnlockedEmail


type Missions
    = ProceedMission
    | ProceededMission
