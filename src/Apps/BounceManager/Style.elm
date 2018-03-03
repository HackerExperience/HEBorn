module Apps.BounceManager.Style exposing (..)

import Css exposing (..)
import Css.Colors as Colors
import Css.Namespace exposing (namespace)
import Utils.Css exposing (transition, Easing(..))
import UI.Common
    exposing
        ( internalPadding
        , flexContainerVert
        , flexContainerHorz
        )
import UI.Colors as Colors
import UI.Icons as Icons
import Apps.BounceManager.Resources exposing (Classes(..), prefix)


ico : Style
ico =
    before
        [ Icons.fontFamily
        , textAlign center
        ]


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Super
            [ width (pct 100)
            , height (pct 100)
            , flexContainerVert
            , bounceManage
            , bounceBuilder
            ]
        , class BtnEdit
            [ ico
            , before [ Icons.edit ]
            ]
        , class BtnDelete
            [ ico
            , before [ Icons.trash ]
            ]
        , class BottomButton
            [ cursor pointer ]
        , class DataBox
            [ width (pct 100)
            ]
        , class BottomButtons
            [ property "align-content" "center"
            , width (pct 100)
            , displayFlex
            ]
        ]


bounceManage : Style
bounceManage =
    withClass Manage
        [ withClass Empty
            [ flexContainerVert
            , justifyContent center
            , children
                [ class MiddleButton
                    [ width (pct 90)
                    , height (px 32)
                    , alignSelf center
                    ]
                ]
            ]
        , children
            [ class BounceList
                [ overflowY auto
                , overflowX hidden
                , children
                    [ class BounceEntry
                        [ borderBottom3 (px 1) solid Colors.black
                        , fontSize (px 12)
                        , internalPadding
                        ]
                    ]
                ]
            ]
        ]


bounceBuilder : Style
bounceBuilder =
    withClass Builder
        [ children
            [ class Name
                [ flexContainerHorz
                , internalPadding
                , justifyContent spaceBetween
                , height (pct 5)
                , children
                    [ class BoxifyMe
                        [ border3 (px 1) solid Colors.boxifyMe
                        , padding (px 2)
                        , display block
                        , width (pct 30)
                        ]
                    , class Buttons
                        []
                    ]
                ]
            , class Building
                [ flexContainerHorz
                , justifyContent spaceBetween
                , internalPadding
                , height (pct 90)
                , children
                    [ server
                    , build
                    ]
                ]
            , class Buttons
                [ flexContainerHorz
                , justifyContent spaceBetween
                , internalPadding
                , height (pct 5)
                , children
                    [ class Button
                        [ height (px 32) ]
                    ]
                ]
            ]
        ]


server : Snippet
server =
    class Servers
        [ flex (int 1)
        , flexContainerVert
        , children
            [ class FilterBox
                []
            , class ServerList
                [ border3 (px 1) solid Colors.black
                , overflowY auto
                , height (pct 45)
                , children
                    [ class HackedServer
                        [ withClass Selected
                            [ backgroundColor Colors.bgSelected
                            ]
                        , withClass Highlight
                            [ backgroundColor Colors.bgHighlight
                            ]
                        , hover
                            [ backgroundColor Colors.bgHover
                            ]
                        ]
                    ]
                ]
            ]
        ]


build : Snippet
build =
    class Build
        [ border3 (px 1) solid Colors.black
        , flex (int 2)
        , overflowY auto
        , children
            [ class BounceMap
                [ children
                    [ class BounceMember
                        [ children
                            [ class BounceNode
                                [ color Colors.bounceNode
                                , height (px 16)
                                , width (px 16)
                                , withClass Selected
                                    [ color Colors.bgSelected ]
                                ]
                            , class MoveMenu
                                [ width (px 96)
                                , height (px 32)
                                , opacity (int 0)
                                , transition 1 "opacity" EaseInOut
                                , withClass Show
                                    [ opacity (int 1)
                                    ]
                                ]
                            ]
                        , hover
                            [ children
                                [ class MoveMenu
                                    [ width (px 96)
                                    , height (px 32)
                                    , opacity (int 1)
                                    ]
                                ]
                            ]
                        ]
                    , class Slot
                        [ width (px 3)
                        , height (px 16)
                        , backgroundColor Colors.black
                        , withClass Selected
                            [ backgroundColor Colors.bgSelected ]
                        , withClass Highlight
                            [ backgroundColor Colors.bgHighlight ]
                        ]
                    ]
                , listStyle none
                ]
            ]
        ]
