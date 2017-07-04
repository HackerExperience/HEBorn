module OS.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (typeSelector)
import Css.Namespace exposing (namespace)
import Css.Utils exposing (transition, easingToString, Easing(..))
import Css.Common exposing (flexContainerVert, flexContainerHorz, globalShadow)
import UI.Colors as Colors


type Classes
    = Session
    | Header
    | Dock
    | Version


type Id
    = Dashboard
    | DesktopVersion


prefix : String
prefix =
    "os"


css : Stylesheet
css =
    (stylesheet << namespace prefix)
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
                    , children
                        [ typeSelector "customSelect"
                            [ height (pct 100)
                            , margin (px -8)
                            , padding (px 7)
                            , display block
                            , flex (int 0)
                            , textAlign center
                            , lineHeight (px 29)
                            , firstOfType
                                [ marginRight (px 8) ]
                            , lastOfType
                                [ marginLeft (px 8)
                                , marginRight (px 8)
                                ]
                            , backgroundColor (hex "FFF")
                            , border3 (px 1) solid Colors.black
                            , children
                                [ typeSelector "selector"
                                    [ position absolute
                                    , minWidth (px 120)
                                    , backgroundColor Colors.black
                                    , color Colors.white
                                    , children
                                        [ typeSelector "customOption"
                                            [ display block
                                            , hover [ backgroundColor Colors.hyperlink ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
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
                            , paddingTop (px 29)
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
