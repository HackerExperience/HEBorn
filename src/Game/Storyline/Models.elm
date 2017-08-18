module Game.Storyline.Models exposing (..)

import Game.Storyline.Missions.Models as Missions


type alias Model =
    { enabled : Bool
    , missions : Missions.Model
    }


initialModel : Model
initialModel =
    { enabled = False
    , missions = Missions.initialModel
    }
