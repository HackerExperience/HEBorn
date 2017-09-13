module Game.Storyline.Messages exposing (Msg(..))

import Game.Storyline.Missions.Messages as Missions
import Game.Storyline.Emails.Messages as Emails
import Events.Events as Events


type Msg
    = Toggle
    | MissionsMsg Missions.Msg
    | EmailsMsg Emails.Msg
    | Event Events.Event
