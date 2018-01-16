module Game.Storyline.Models exposing (..)

import Game.Storyline.Missions.Models as Missions
import Game.Storyline.Emails.Models as Emails


type alias Model =
    { enabled : Bool
    , missions : Missions.Model
    , emails : Emails.Model
    }


initialModel : Model
initialModel =
    { enabled = True
    , missions = Missions.initialModel
    , emails = Emails.initialModel
    }


isActive : Model -> Bool
isActive =
    .enabled


getMissions : Model -> Missions.Model
getMissions =
    .missions


getEmails : Model -> Emails.Model
getEmails =
    .emails
