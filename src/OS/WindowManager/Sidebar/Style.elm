module OS.WindowManager.Sidebar.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import OS.WindowManager.Sidebar.Resources exposing (..)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Super
            [ flex (int 0)
            , width (px 320)
            , height (pct 100)
            , marginRight (px -320)
            , overflowY auto
            , withClass Visible
                [ marginRight (px 0) ]
            ]
        ]
