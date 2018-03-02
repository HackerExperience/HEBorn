module Game.Storyline.DynamicStyle exposing (dynCss)

import Css exposing (Stylesheet, stylesheet)
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)
import Game.Storyline.Models exposing (Model)
import UI.DynStyles.Hide.OS exposing (..)
import UI.DynStyles.Show.OS exposing (..)


dynCss : Model -> List Stylesheet
dynCss model =
    [ hideAllDock
    , showDockIcon DesktopApp.Browser
    , showDockIcon DesktopApp.Email
    ]
