module Apps.BounceManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Common exposing (internalPadding)
import UI.Colors as Colors
import Apps.BounceManager.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class BounceEntry
            [ borderBottom3 (px 1) solid Colors.black
            , fontSize (px 12)
            , internalPadding
            ]
        , class BounceNode
            [ borderBottom3 (px 1) solid Colors.black
            , fontSize (px 12)
            , internalPadding
            , borderRadius (px 8)
            ]
        ]
