module Core.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (typeSelector, body, li, main_, header, footer, nav)
import Css.Namespace exposing (namespace)
import Css.Utils exposing (unselectable)
import Core.Resources exposing (prefix, appId)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ body
            [ displayFlex
            , minWidth (vw 100)
            , minHeight (vh 100)
            , maxWidth (vw 100)
            , maxHeight (vh 100)
            , overflow hidden
            , margin (px 0)
            , cursor default
            , unselectable
            ]
        , id appId
            [ width (pct 100)
            , minHeight (pct 100)
            ]
        ]
