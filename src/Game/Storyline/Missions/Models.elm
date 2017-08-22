module Game.Storyline.Missions.Models exposing (..)

import Apps.Apps exposing (App(..))
import Game.Storyline.Missions.Actions exposing (Action(..))


type alias Model =
    List Mission


type alias Step =
    List Action


type alias Mission =
    { id : MissionKey
    , done : List Step
    , now : Step
    , todo : List Step
    }


type MissionKey
    = FirstMission


initMission mk =
    let
        create =
            Mission mk []
    in
        case mk of
            FirstMission ->
                create [ RunApp ExplorerApp, RunFile "003" ] []


initialModel : Model
initialModel =
    [ initMission FirstMission ]
