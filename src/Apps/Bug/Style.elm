module Apps.Bug.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Apps.Bug.Resources exposing (..)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        []
