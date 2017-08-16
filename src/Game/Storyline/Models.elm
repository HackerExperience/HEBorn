module Game.Storyline.Models exposing (..)


type alias Model =
    { enabled : Bool
    , missions : Missions
    }


type Mission
    = FirstMission


type alias Missions =
    List Mission


initialModel : Model
initialModel =
    { enabled = True
    , missions = [ FirstMission ]
    }
