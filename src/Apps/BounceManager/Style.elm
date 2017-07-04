module Apps.BounceManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


type Classes
    = Dummy


prefix : String
prefix =
    "bouncemngr"


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        []
