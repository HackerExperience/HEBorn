module Apps.TaskManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


type Classes
    = X


css : Stylesheet
css =
    (stylesheet << namespace "logvw")
        [ class X
            []
        ]
