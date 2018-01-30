module UI.DynStyles.Hide.OS exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import OS.WindowManager.Dock.Resources as Dock


hideAllDock : Stylesheet
hideAllDock =
    (stylesheet << namespace Dock.prefix)
        [ class Dock.Item
            [ display none
            ]
        ]
