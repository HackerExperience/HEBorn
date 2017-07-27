module Apps.LocationPicker.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Apps.LocationPicker.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Super
            [ height (pct 100)
            , display block
            ]
        ]
