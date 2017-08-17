module Game.Storyline.Models exposing (..)


type alias ID =
    String


type Objective
    = RunFile ID


type alias Model =
    { enabled : Bool
    , missions : Missions
    }


type alias Step =
    List Objective


type alias Mission =
    { id : MissionKey
    , done : List Step
    , now : Step
    , todo : List Step
    }


type alias Missions =
    List Mission


type MissionKey
    = FirstMission


initMission mk =
    let
        create =
            Mission mk []
    in
        case mk of
            FirstMission ->
                create [ RunFile "003" ] []


initialModel : Model
initialModel =
    { enabled = False
    , missions = [ initMission FirstMission ]
    }
