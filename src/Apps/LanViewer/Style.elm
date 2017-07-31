module Apps.LanViewer.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Apps.LanViewer.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Todo
            []
        ]
