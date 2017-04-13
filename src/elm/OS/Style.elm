module OS.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (body,  main_, header, footer)
import Css.Namespace exposing (namespace)
import Css.Utils exposing (transition, easingToString, Easing(..))
import Css.Common exposing (flexContainerVert, flexContainerHorz, globalShadow)

type Id
    = Dashboard

css =
    (stylesheet << namespace "os")
        [ id Dashboard   
            [ width (pct 100)
            , minHeight (pct 100)
            , flexContainerVert
            ]
        , header
            [ backgroundColor (hex "EEE")
            , flexContainerHorz
            , justifyContent flexEnd
            , padding (px 8)
            , globalShadow
            ]
        , main_
            [ flex (int 1) ]
        , footer
            [ flexContainerHorz
            , justifyContent center
            , position relative
            , minHeight (px 60)
            , marginBottom (px -60)
            , paddingTop (px 8)
            , transition 0.15 "margin" EaseOut
            , hover
                [ marginBottom (px 0) ]
            ]
        ]
