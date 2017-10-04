module OS.Style exposing (..)

import Css exposing (..)
import Css.Common exposing (flexContainerVert, flexContainerHorz, globalShadow)
import Css.Elements exposing (typeSelector, ul, li, div, h6)
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
                , toasts
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
        , backgroundPosition center
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
            [ logo
            , connection
            , taskbar
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
        , maxWidth (px 120)
        , overflow hidden
        , whiteSpace noWrap
        , textOverflow ellipsis
        , before
            [ Icons.fontFamily ]
        , children
            [ typeSelector "selector"
                [ menu
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


menu : Style
menu =
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


logo : Snippet
logo =
    class Logo
        [ before [ Icons.fontFamily, Icons.osLogo ]
        , flex (int 1)
        ]


connection : Snippet
connection =
    class Connection
        [ children
            [ customSelect
            , popup
            , contextSwitch
            ]
        , flexContainerHorz
        , flex (int 0)
        ]


taskbar : Snippet
taskbar =
    class Taskbar
        [ flex (int 1)
        , display block
        , children
            [ indicator
            , bubble
            , notifications
            , account
            ]
        , textAlign right
        ]


bubble : Snippet
bubble =
    typeSelector bubbleNode
        [ position absolute
        , display inlineBlock
        , width (px 15)
        , height (px 15)
        , textAlign center
        , backgroundColor Colors.bgModal
        , color Colors.white
        , fontSize (px 10)
        , lineHeight (px 15)
        , margin4 (px -4) (px 0) (px 0) (px -22)
        , borderRadius (pct 100)
        , withClass Empty [ display none ]
        ]


indicator : Snippet
indicator =
    typeSelector indicatorNode
        [ position relative
        , display inlineBlock
        , marginRight (px 16)
        , before
            [ Icons.fontFamily
            ]
        , withClass ChatIco
            [ before [ Icons.chat ] ]
        , withClass ServersIco
            [ before [ Icons.notifications ] ]
        ]


notifications : Snippet
notifications =
    class Notification
        [ child div notificationMenu ]


taskbarMenu : Style
taskbarMenu =
    batch
        [ menu
        , right (px 0)
        , width (px 320)
        , margin (px 0)
        , backgroundColor Colors.white
        , fontSize (px 12)
        ]


notificationMenu : List Style
notificationMenu =
    [ taskbarMenu
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


account : Snippet
account =
    class Account
        [ before [ Icons.accountMenu ]
        , child div
            [ taskbarMenu
            , child ul
                [ listStyle none
                , padding (px 0)
                , margin (px 0)
                , child li
                    [ borderBottom3 (px 1) solid Colors.separator
                    , padding2 (px 0) (px 8)
                    ]
                ]
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
