module Apps.BounceManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Common
    exposing
        ( internalPadding
        , flexContainerVert
        , flexContainerHorz
        )
import UI.Colors as Colors
import Apps.BounceManager.Resources exposing (Classes(..), prefix)


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
            [ class BounceEntry
                [ borderBottom3 (px 1) solid Colors.black
                , fontSize (px 12)
                , internalPadding
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
                        [ border3 (px 1) solid (hex "444")
                        , padding (px 2)
                        , display block
                        , width (pct 30)
                        ]
                    ]
                ]
            , class Building
                [ flexContainerHorz
                , justifyContent spaceBetween
                , internalPadding
                , height (pct 90)
                , children
                    [ class Servers
                        [ flex (int 1)
                        , flexContainerVert
                        , children
                            [ class Filter
                                [ flex (int 1) ]
                            , class ServerList
                                [ border3 (px 1) solid Colors.black
                                , overflowY auto
                                , flex (int 9)
                                , children
                                    [ class HackedServer
                                        [ withClass Selected
                                            [ color (hex "f00")
                                            ]
                                        , hover
                                            [ backgroundColor (hex "00f")
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    , class Build
                        [ border3 (px 1) solid Colors.black
                        , flex (int 2)
                        , overflowY auto
                        , children
                            [ class BounceMap
                                [ children
                                    [ class BounceNode
                                        [ color (hex "BFFF00")
                                        , height (px 16)
                                        , width (px 16)
                                        , withClass Selected
                                            [ color (hex "00FFFF") ]
                                        ]
                                    , class Slot
                                        [ width (px 1)
                                        , height (px 16)
                                        , backgroundColor Colors.black
                                        , withClass Selected
                                            [ backgroundColor (hex "FF0000") ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
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
