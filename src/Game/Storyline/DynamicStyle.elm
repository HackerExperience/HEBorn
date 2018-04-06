module Game.Storyline.DynamicStyle exposing (dynCss)

import Css exposing (Stylesheet, stylesheet)
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)
import Game.Storyline.Models exposing (Model)


dynCss : Model -> List Stylesheet
dynCss model =
    []
