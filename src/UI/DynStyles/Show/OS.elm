module UI.DynStyles.Show.OS exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Utils as Css exposing (withAttribute)
import Utils.Html.Attributes exposing (appAttrTag)
import OS.SessionManager.Dock.Resources as Dock
import Apps.Models as Apps
import Apps.Apps exposing (App)


showDockIcon : App -> Stylesheet
showDockIcon app =
    (stylesheet << namespace Dock.prefix)
        [ class Dock.Item
            [ withAttribute (Css.EQ appAttrTag (Apps.name app))
                [ display block
                ]
            ]
        ]
