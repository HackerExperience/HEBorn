module Apps.CtrlPanel.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Apps.CtrlPanel.Resources exposing (..)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        []
