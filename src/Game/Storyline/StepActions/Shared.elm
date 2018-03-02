module Game.Storyline.StepActions.Shared exposing (Action(..))

import Game.Meta.Types.Context exposing (Context)
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)


type alias ID =
    String


type Action
    = RunFile ID
    | GoApp DesktopApp Context
