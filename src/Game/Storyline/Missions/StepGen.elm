module Game.Storyline.Missions.StepGen exposing (fromStep)

import Game.Storyline.Missions.Missions exposing (Mission(..))
import Game.Storyline.Missions.Actions exposing (Action(..))
import Game.Meta.Types exposing (Context(..))
import Apps.Apps exposing (App(..))


type alias ID =
    String


fromStep : Mission -> ID -> List Action
fromStep mission id =
    case mission of
        NoMission ->
            []

        Tutorial ->
            tutorialStep id


tutorialStep : ID -> List Action
tutorialStep id =
    case id of
        "001" ->
            [ GoApp ExplorerApp Gateway
            , RunFile "003"
            ]

        _ ->
            []
