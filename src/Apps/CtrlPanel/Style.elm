module Apps.CtrlPanel.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Apps.CtrlPanel.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Todo
            []
        ]
