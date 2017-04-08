module Core.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, li, main_, header, footer, nav)
import Css.Namespace exposing (namespace)


css : Stylesheet
css =
    (stylesheet << namespace "core")
    [ body
        [ displayFlex
        , minWidth (px 1280)
        ]
    ]
