module Apps.ConnManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


type Classes
    = Dummy


css : Stylesheet
css =
    (stylesheet << namespace "connmngr")
        []
