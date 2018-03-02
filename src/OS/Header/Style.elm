module OS.Header.Style exposing (..)

import Css exposing (..)
import Css.Common exposing (flexContainerVert, flexContainerHorz, globalShadow)
import Css.Elements exposing (typeSelector, ul, li, div, h6)
import Css.Namespace exposing (namespace)
import Css.Utils as Css exposing (..)
import Css.Icons as Icons
import UI.Style exposing (clickableBox)
import UI.Colors as Colors
import Css.Colors
import OS.Header.Resources exposing (..)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Header
            [ backgroundColor Colors.bgWindow
            , flexContainerHorz
            , padding (px 8)
            , globalShadow
            , children
                [ logo
                , connection
                , taskbar
                , networkTongue
                ]
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


networkTongue : Snippet
networkTongue =
    class Network
        [ position absolute
        , left (px 0)
        , right (px 0)
        , margin3 (px 32) auto (px 0)
        , width (px 320)
        , children
            [ class AvailableNetworks
                [ margin (px 0)
                , overflowY scroll
                , transition 0.5 "max-height" EaseOut
                , height auto
                , maxHeight (vh 50)
                , withAttribute (NOT (BOOL expandedMenuAttrTag))
                    [ maxHeight (px 0) ]
                ]
            , class ActiveNetwork
                [ flexContainerHorz
                , children
                    [ everything
                        [ firstChild [ flex (int 1) ]
                        , lastChild
                            [ flex (int 0)
                            , width (px 32)
                            ]
                        , lineHeight (px 25)
                        , textAlign center
                        ]
                    ]
                ]
            ]
        , backgroundColor Colors.bgWindow
        , globalShadow
        ]


logo : Snippet
logo =
    class Logo
        [ before [ Icons.fontFamily, Icons.osLogo ]
        , flex (int 1)
        ]


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


connection : Snippet
connection =
    class Connection
        [ children
            [ customSelect
            , sbounce
            , bounceMenu
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
            , account
            , class ChatIco [ child div [ taskbarMenu ] ]
            , class ServersIco [ child div [ taskbarMenu ] ]
            ]
        , descendants
            [ notifications ]
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


notifications : Snippet
notifications =
    class Notification
        [ child ul
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
    class AccountIco
        [ before [ Icons.accountMenu ]
        , child div
            [ taskbarMenu
            , child ul
                [ listStyle none
                , padding (px 0)
                , margin (px 0)
                , child li
                    [ borderTop3 (px 1) solid Colors.separator
                    , padding (px 8)
                    ]
                ]
            ]
        ]


sbounce : Snippet
sbounce =
    class SBounce
        [ clickableBox
        , before [ Icons.fontFamily, Icons.bounce ]
        , minWidth (px 120)
        , maxWidth (px 120)
        , textAlign center
        , overflow hidden
        , whiteSpace noWrap
        , textOverflow ellipsis
        ]


bounceMenu : Snippet
bounceMenu =
    class BounceMenu
        [ display none
        , position absolute
        , marginTop (px 35)
        , border3 (px 1) solid Colors.black
        , backgroundColor Colors.bgWindow
        , flexDirection row
        , width (px 500)
        , height (px 200)
        , zIndex (int 5)
        , children
            [ bounceMenuLeft
            , bounceMenuRight
            ]
        , withClass Selected
            [ displayFlex
            ]
        ]


bounceMenuLeft : Snippet
bounceMenuLeft =
    class BounceMenuLeft
        [ width (pct 25)
        , displayFlex
        , flexDirection column
        , alignItems center
        , borderRight3 (px 1) solid Colors.black
        , children
            [ bounceList
            ]
        , withClass Hidden [ display none ]
        ]


bounceMenuRight : Snippet
bounceMenuRight =
    class BounceMenuRight
        [ displayFlex
        , flexDirection column
        , width (pct 75)
        , children
            [ bounceMembers
            , bounceOptions
            ]
        , withClass ReadOnly
            [ minWidth (pct 100)
            , maxWidth (pct 100)
            , minHeight (pct 100)
            , maxHeight (pct 100)
            ]
        ]


bounceList : Snippet
bounceList =
    class BounceList
        [ displayFlex
        , flexDirection column
        , minHeight (pct 87.5)
        , maxHeight (pct 87.5)
        , overflowX hidden
        , width (pct 100)
        , children
            [ bounceListEntry
            ]
        ]


bounceListEntry : Snippet
bounceListEntry =
    class BounceListEntry
        [ borderBottom3 (px 1) solid Colors.black
        , width (pct 100)
        , minHeight (px 32)
        , maxHeight (px 32)
        , textAlign center
        , hover [ backgroundColor Colors.bgHover ]
        ]


bounceMember : Snippet
bounceMember =
    class BounceMember
        []


bounceMembers : Snippet
bounceMembers =
    class BounceMembers
        [ displayFlex
        , flexDirection row
        , minWidth (pct 89.5)
        , maxWidth (pct 89.5)
        , minHeight (px 143)
        , maxHeight (px 143)
        , margin (px 16)
        , overflowX auto
        , children
            [ bounceMember
            ]
        , withClass ReadOnly
            [ minWidth (pct 100)
            , maxWidth (pct 100)
            , minHeight (pct 100)
            , maxHeight (pct 100)
            , margin (px 0)
            ]
        , withClass Empty
            [ alignItems center
            , justifyContent center
            ]
        ]


bounceOptions : Snippet
bounceOptions =
    class BounceOptions
        [ displayFlex
        , justifyContent spaceBetween
        , flex (int 0)
        , width (pct 95)
        , height (pct 12.5)
        , padding2 (px 0) (px 8)
        , withClass Hidden [ display none ]
        ]


popup : Snippet
popup =
    typeSelector "popup"
        [ zIndex (int 3) ]
