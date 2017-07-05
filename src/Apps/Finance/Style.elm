module Apps.Finance.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import UI.Colors as Colors
import Apps.Finance.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Dummy
            []
        ]
