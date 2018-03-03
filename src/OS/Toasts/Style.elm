module OS.Toasts.Style exposing (..)

import Css exposing (..)
import Css.Colors as Colors
import Css.Elements exposing (div, h6)
import Css.Namespace exposing (namespace)
import Utils.Css exposing (..)
import OS.Toasts.Resources exposing (..)
import UI.Colors as Colors


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Toasts
            [ position absolute
            , right (px 2)
            , bottom (px 2)
            , width (px 240)
            , child div
                [ color Colors.white
                , padding (px 8)
                , borderRadius (px 8)
                , backgroundColor (rgba 0 0 0 0.9)
                , marginTop (px 2)
                , minHeight (px 92)
                , maxHeight (px 92)
                , overflow hidden
                , transition 0.5 "all" Linear
                , withClass Fading
                    [ opacity (int 0)
                    , marginBottom (px -94)
                    ]
                , child h6 [ margin2 (px 4) (px 0) ]
                ]
            ]
        ]
