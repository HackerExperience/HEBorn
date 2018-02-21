module Game.Storyline.StepActions.Shared exposing (Action(..))

import Game.Meta.Types.Context exposing (Context)
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)


type alias ID =
    String


type Action
    = RunFile ID
    | GoApp DesktopApp Context
