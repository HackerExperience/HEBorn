module Landing.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import UI.Colors as Colors
import Landing.Resources exposing (..)


css : Stylesheet
css =
    stylesheet
        [ id viewId
            [ color Colors.white
            ]
        ]
