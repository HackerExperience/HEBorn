module Game.Storyline.StepActions.Helper exposing (initialActions)

import Game.Storyline.Shared exposing (Step(..))
import Game.Storyline.StepActions.Shared exposing (Action(..))
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)


initialActions : Step -> List Action
initialActions step =
    case step of
        Tutorial_SetupPC ->
            []

        Tutorial_DownloadCracker ->
            [ GoApp DesktopApp.Browser Gateway
            ]

        Tutorial_NastyVirus ->
            []
