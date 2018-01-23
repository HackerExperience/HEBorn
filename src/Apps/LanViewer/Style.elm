module Apps.LanViewer.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Apps.LanViewer.Resources exposing (..)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        []
