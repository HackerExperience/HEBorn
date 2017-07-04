module Apps.BounceManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Apps.BounceManager.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        []
