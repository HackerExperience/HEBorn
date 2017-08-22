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
    { enabled = False
    , missions = Missions.initialModel
    , emails = Emails.initialModel
    }
