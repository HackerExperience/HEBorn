module UI.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (input, span)
import Css.Common exposing (internalPadding, internalPaddingSz, flexContainerHorz)


css : Stylesheet
css =
    (stylesheet << namespace "ui")
        [ selector "verticallist"
            [ overflowY scroll
            , flex (int 1)
            ]
        , selector "progressBar"
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
        , selector "filterHeader"
            [ flexContainerHorz
            , borderBottom3 (px 1) solid (hex "000")
            , internalPadding
            , lineHeight (px 32)
            ]
        , selector "flagsFilterPanel"
            [ flex (int 1)
            , fontSize (px 32)
            ]
        , selector "filterText"
            [ children
                [ input
                    [ flex (int 1)
                    , marginLeft (px 18)
                    , padding (px 3)
                    , borderRadius (px 12)
                    , border3 (px 1) solid (hex "000")
                    ]
                ]
            ]
        ]
