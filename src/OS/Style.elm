module OS.Style exposing (..)

import Css exposing (..)
import Css.Common exposing (flexContainerVert, flexContainerHorz, globalShadow)
import Css.Elements exposing (typeSelector, ul, li, div, h6)
import Css.Namespace exposing (namespace)
import Css.Utils as Css exposing (..)
import Css.Icons as Icons
import UI.Style exposing (clickableBox)
import UI.Colors as Colors
import Css.Colors
import OS.Resources exposing (..)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ id Dashboard
            [ dashboard
            , children
                [ console
                , class Session
                    [ flex (int 1)
                    , flexContainerVert
                    , children [ dock ]
                    ]
                , toasts
                , class Version
                    [ position absolute
                    , left (px 0)
                    , bottom (px 0)
                    , color Colors.white
                    ]
                ]
            ]
        , conditional
        ]


dashboard : Style
dashboard =
    batch
        [ width (pct 100)
        , minHeight (pct 100)
        , flexContainerVert
        , position relative
        , zIndex (int 0)
        , backgroundImage <| url "//raw.githubusercontent.com/elementary/wallpapers/master/Photo%20by%20SpaceX.jpg"
        , backgroundSize cover
        , backgroundPosition center
        , fontFamily sansSerif
        , fontFamilies [ "Open Sans" ]
        , Css.fontWeight (int 300)
        ]


console : Snippet
console =
    class LogConsole
        [ width (pct 100)
        , marginTop (px 41)
        , flexContainerVert
        , position absolute
        , zIndex (int -1)
        , backgroundColor (rgba 0 0 0 0.5)
        , color (hex "00FF00")
        , fontFamily monospace
        , fontFamilies [ "Monospace" ]
        , children
            [ div
                [ children
                    [ class LogConsoleHeader
                        [ justifyContent spaceBetween
                        , children
                            [ class BFRequest
                                [ color Css.Colors.blue ]
                            , class BFReceive
                                [ color Css.Colors.yellow ]
                            , class BFJoin
                                [ color Css.Colors.lime ]
                            , class BFJoinAccount
                                [ color Css.Colors.green ]
                            , class BFJoinServer
                                [ color Css.Colors.maroon ]
                            , class BFOther
                                [ color Css.Colors.gray ]
                            , class BFNone
                                [ color Css.Colors.silver ]
                            , class BFEvent
                                [ color Css.Colors.orange ]
                            , class BFError
                                [ color Css.Colors.red ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


dock : Snippet
dock =
    class Dock
        [ flexContainerHorz
        , justifyContent center
        , position absolute
        , width (vw 100)
        , bottom zero
        , zIndex (int 1)
        , minHeight (px 60)
        , paddingTop (px 29)
        , transition 0.15 "margin" EaseOut
        , withClass AutoHide
            [ marginBottom (px -60)
            , hover
                [ marginBottom (px 0) ]
            ]
        ]


toasts : Snippet
toasts =
    class Toasts
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


conditional : Snippet
conditional =
    id Dashboard
        [ withAttribute (Css.NOT <| Css.EQ gameVersionAttrTag devVersion)
            [ child (class LogConsole)
                [ display none
                , opacity (int 0)
                ]
            ]
        ]
