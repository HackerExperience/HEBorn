module OS.Style exposing (..)

import Css exposing (..)
import Css.Common exposing (flexContainerVert, flexContainerHorz, globalShadow)
import Css.Elements exposing (typeSelector)
import Css.Namespace exposing (namespace)
import Css.Utils exposing (transition, easingToString, Easing(..))
import UI.Colors as Colors
import OS.Resources exposing (..)


headerChildren : Style
headerChildren =
    children
        [ typeSelector "customSelect"
            [ height (pct 100)
            , marginTop (px -8)
            , marginBottom (px -8)
            , padding (px 7)
            , display block
            , flex (int 0)
            , textAlign center
            , lineHeight (px 29)
            , firstOfType
                [ marginLeft (px -8) ]
            , backgroundColor Colors.white
            , border3 (px 1) solid Colors.black
            , minWidth (px 120)
            , overflow hidden
            , whiteSpace noWrap
            , textOverflow ellipsis
            , children
                [ typeSelector "selector"
                    [ position absolute
                    , minWidth (px 120)
                    , backgroundColor Colors.black
                    , color Colors.white
                    , zIndex (int 2)
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


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ id Dashboard
            [ width (pct 100)
            , minHeight (pct 100)
            , flexContainerVert
            , position relative
            , zIndex (int 0)
            , backgroundImage <| url "https://raw.githubusercontent.com/elementary/wallpapers/master/Photo%20by%20SpaceX.jpg"
            , backgroundSize cover
            , fontFamily sansSerif
            , fontFamilies [ "Open Sans" ]
            , Css.fontWeight (int 300)
            , children
                [ class Header
                    [ backgroundColor Colors.bgWindow
                    , flexContainerHorz
                    , padding (px 8)
                    , globalShadow
                    , headerChildren
                    , children [ typeSelector "popup" [ zIndex (int 3) ] ]
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
                            , zIndex (int 1)
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
                    , color Colors.white
                    ]
                ]
            ]
        ]
