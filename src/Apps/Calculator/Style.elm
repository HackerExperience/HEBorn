module Apps.Calculator.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (ul, li, div, span, button)
import Utils.Css exposing (..)
import UI.Common exposing (..)
import UI.Colors as Colors
import Apps.Calculator.Resources exposing (..)


type Classes
    = Window
    | Content


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class MainContainer
            [ displayFlex
            , flexDirection column
            , padding (px 10)
            , children
                [ class DisplayContainer
                    [ displayFlex
                    , border3 (px 1) solid (hex "000000")
                    , backgroundColor (hex "ffffff")
                    , flex (int 1)
                    , padding (px 4)
                    , overflow hidden
                    ]
                , class ButtonsContainer
                    [ displayFlex
                    , flexDirection row
                    , flexWrap wrap
                    , height (pct 80)
                    , children
                        [ class ButtonsContainerSub
                            [ display block
                            , flexDirection row
                            , flexWrap wrap
                            , height (pct 40)
                            , width (pct 75)
                            , children
                                [ class ZeroBtn
                                    [ width (pct 66.66)
                                    , height (pct 50)
                                    ]
                                , class NormalSubBtn
                                    [ width (pct 33.33)
                                    , height (pct 50)
                                    ]
                                ]
                            ]
                        , class
                            NormalBtn
                            [ width (pct 25)
                            , height (pct 20)
                            ]
                        , class ApplyBtn
                            [ height (pct 40.25)
                            , width (pct 25)
                            ]
                        , class DoubleWidthBtn
                            [ width (pct 50)
                            , height (pct 20)
                            , color (hex "FF0000")
                            ]
                        , button
                            [ display block
                            , fontFamily monospace
                            ]
                        ]
                    ]
                ]
            ]
        ]
