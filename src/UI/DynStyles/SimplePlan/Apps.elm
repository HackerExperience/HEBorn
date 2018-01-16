module UI.DynStyles.SimplePlan.Apps exposing (..)

import Css exposing (..)
import Css.Elements exposing (typeSelector)
import Css.Namespace exposing (namespace)
import Apps.Browser.Resources as B


simpleBrowser : Stylesheet
simpleBrowser =
    (stylesheet << namespace B.prefix)
        [ class B.Window
            [ children
                [ class B.Toolbar
                    [ display none ]
                , typeSelector "panel"
                    [ display none ]
                ]
            ]
        ]
