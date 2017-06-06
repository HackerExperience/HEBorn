module UI.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Common exposing (internalPaddingSz)


css : Stylesheet
css =
    (stylesheet << namespace "ui")
        [ selector "progressbar"
            [ display inlineBlock
            , borderRadius (vw 100)
            , overflow hidden
            , backgroundColor (hex "444")
            , position relative
            , zIndex (int 0)
            , width (px 80)
            , textAlign center
            , children
                [ selector "fill"
                    [ position absolute
                    , display block
                    , zIndex (int 0)
                    , backgroundColor (hex "11B")
                    , height (pct 100)
                    ]
                , selector "label"
                    [ position relative
                    , margin2 (px 0) auto
                    , zIndex (int 1)
                    , color (hex "EEE")
                    ]
                ]
            ]
        ]
