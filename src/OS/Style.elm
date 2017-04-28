module OS.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, main_, header, footer)
import Css.Namespace exposing (namespace)
import Css.Utils exposing (transition, easingToString, Easing(..))
import Css.Common exposing (flexContainerVert, flexContainerHorz, globalShadow)


type Id
    = Dashboard
    | DesktopVersion


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
            [ flex (int 1)
            , flexContainerVert
            ]
        , footer
            [ flexContainerHorz
            , justifyContent center
            , position absolute
            , width (vw 100)
            , bottom zero
            , zIndex (int 1699999)
            , minHeight (px 60)
            , paddingTop (px 8)
            , transition 0.15 "margin" EaseOut
            , withClass "autoHide"
                [ marginBottom (px -60)
                , hover
                    [ marginBottom (px 0) ]
                ]
            ]
        , id DesktopVersion
            []
        ]
