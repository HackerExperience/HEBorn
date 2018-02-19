module Game.Storyline.StepActions.Helper exposing (fromStep)

import Game.Storyline.Quests.Shared exposing (Step(..))
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)


fromStep : Step -> List Action
fromStep step =
    case step of
        Tutorial_SetupPC ->
            []

        Tutorial_DownloadCracker ->
            [ GoApp DesktopApp.Browser Gateway
            ]
