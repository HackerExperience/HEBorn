module Game.Storyline.Missions.StepGen exposing (fromStep)

import Game.Storyline.Missions.Missions exposing (Mission(..))
import Game.Storyline.Missions.Actions exposing (Action(..))
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)


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
        "tutorial@download_cracker_public_ftp" ->
            [ GoApp DesktopApp.Browser Gateway

            --, GoAddress
            ]

        "001" ->
            [ GoApp DesktopApp.Explorer Gateway
            , RunFile "003"
            ]

        _ ->
            []
