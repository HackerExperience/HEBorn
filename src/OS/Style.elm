module OS.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Utils exposing (transition, easingToString, Easing(..))
import Css.Common exposing (flexContainerVert, flexContainerHorz, globalShadow)


type Classes
    = Session
    | Header
    | Dock
    | Version


type Id
    = Dashboard
    | DesktopVersion


css : Stylesheet
css =
    (stylesheet << namespace "os")
        [ id Dashboard
            [ width (pct 100)
            , minHeight (pct 100)
            , flexContainerVert
            , position relative
            , zIndex (int 0)
            , children
                [ class Header
                    [ backgroundColor (hex "EEE")
                    , flexContainerHorz
                    , padding (px 8)
                    , globalShadow
                    ]
                , class Session
                    [ flex (int 1)
                    , flexContainerVert
                    , children
                        [ class Dock
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
                        ]
                    ]
                , class Version
                    [ position absolute
                    , left (px 0)
                    , bottom (px 0)
                    , color (hex "DDD")
                    ]
                ]
            ]
        ]
