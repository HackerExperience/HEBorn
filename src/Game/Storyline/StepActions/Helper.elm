module Game.Storyline.StepActions.Helper exposing (initialActions)

import Game.Storyline.Quests.Shared exposing (Step(..))
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)


initialActions : Step -> List Action
initialActions step =
    case step of
        Tutorial_SetupPC ->
            []

        Tutorial_DownloadCracker ->
            [ GoApp DesktopApp.Browser Gateway
            ]
