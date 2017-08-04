module OS.Style exposing (..)

import Css exposing (..)
import Css.Common exposing (flexContainerVert, flexContainerHorz, globalShadow)
import Css.Elements exposing (typeSelector, ul, li, div)
import Css.Namespace exposing (namespace)
import Css.Utils exposing (..)
import Css.Icons as Icons
import UI.Style exposing (clickableBox)
import UI.Colors as Colors
import OS.Resources exposing (..)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ id Dashboard
            [ dashboard
            , children
                [ header
                , class Session
                    [ flex (int 1)
                    , flexContainerVert
                    , children [ dock ]
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
        , fontFamily sansSerif
        , fontFamilies [ "Open Sans" ]
        , Css.fontWeight (int 300)
        ]


header : Css.Snippet
header =
    class Header
        [ backgroundColor Colors.bgWindow
        , flexContainerHorz
        , padding (px 8)
        , globalShadow
        , children
            [ customSelect
            , popup
            , contextSwitch
            , notifications
            , logo
            ]
        ]


customSelect : Snippet
customSelect =
    typeSelector "customSelect"
        [ clickableBox
        , display inlineBlock
        , flex (int 0)
        , margin2 (px 0) (px 8)
        , padding2 (px 0) (px 8)
        , minWidth (px 120)
        , overflow hidden
        , whiteSpace noWrap
        , textOverflow ellipsis
        , before
            [ Icons.fontFamily ]
        , children
            [ typeSelector "selector"
                [ hoverMenu
                , children
                    [ typeSelector "customOption"
                        [ display block
                        , padding2 (px 0) (px 8)
                        , hover [ backgroundColor Colors.bgSelected ]
                        ]
                    ]
                ]
            ]
        , nest [ withClass SGateway, before ] [ Icons.gateway ]
        , nest [ withClass SBounce, before ] [ Icons.bounce ]
        , nest [ withClass SEndpoint, before ] [ Icons.endpoint ]
        ]


hoverMenu : Style
hoverMenu =
    batch
        [ position absolute
        , border3 (px 1) solid (rgba 49 54 59 0.2)
        , minWidth (px 120)
        , zIndex (int 2)
        , backgroundColor Colors.separator
        , color Colors.black
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


popup : Snippet
popup =
    typeSelector "popup"
        [ zIndex (int 3) ]


contextSwitch : Snippet
contextSwitch =
    class Context
        [ before [ Icons.fontFamily, Icons.contextSelect ]
        , nest [ withClass Selected, before ]
            [ Icons.contextSelected
            , cursor default
            ]
        , cursor pointer
        ]


notifications : Snippet
notifications =
    typeSelector notificationsNode
        [ position relative
        , marginRight (px 16)
        , before
            [ Icons.fontFamily
            ]
        , child div
            [ hoverMenu
            , display none
            , right (px 0)
            , width (px 320)
            , margin (px 0)
            , backgroundColor Colors.white
            , fontSize (px 12)
            , child ul
                [ listStyle none
                , padding (px 0)
                , margin (px 0)
                , child li
                    [ borderBottom3 (px 1) solid Colors.separator
                    , padding2 (px 0) (px 8)
                    , firstChild
                        [ flexContainerHorz
                        , backgroundColor Colors.bgSelected
                        ]
                    , lastChild
                        [ borderBottom (px 0)
                        , textAlign center
                        ]
                    ]
                ]
            ]
        , nest [ hover, child div ]
            [ display block ]
        , withClass NChat
            [ before [ Icons.chat ] ]
        , withClass NAcc
            [ before [ Icons.notifications ] ]
        ]


logo : Snippet
logo =
    class Logo
        [ before [ Icons.fontFamily, Icons.osLogo ] ]
