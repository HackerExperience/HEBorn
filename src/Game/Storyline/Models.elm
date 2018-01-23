module Game.Storyline.Models exposing (..)

import Game.Storyline.Missions.Models as Missions
import Game.Storyline.Emails.Models as Emails


type alias Model =
    { missions : Missions.Model
    , emails : Emails.Model
    }


initialModel : Model
initialModel =
    { missions = Missions.initialModel
    , emails = Emails.initialModel
    }


getMissions : Model -> Missions.Model
getMissions =
    .missions


getEmails : Model -> Emails.Model
getEmails =
    .emails


setMissions : Missions.Model -> Model -> Model
setMissions missions model =
    { model | missions = missions }


setEmails : Emails.Model -> Model -> Model
setEmails emails model =
    { model | emails = emails }
