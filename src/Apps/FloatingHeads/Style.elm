module Apps.FloatingHeads.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (ul, li, div, span)
import Css.Icons as Icon
import Css.Utils exposing (..)
import Css.Common exposing (..)
import UI.Colors as Color
import Apps.FloatingHeads.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class WindowHeader
            [ width (pct 100)
            , height (px 16)
            , children
                [ class WindowHeaderButtons
                    [ displayFlex
                    , width (px 150)
                    , height (pct 100)
                    , alignItems flexEnd
                    , children
                        [ class HeaderButtons
                            [ children
                                [ class HeaderBtnClose
                                    [ before
                                        [ Icon.windowClose ]
                                    , color (hex "f25156")
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        , class Super
            [ flexDirection row
            , displayFlex
            , children
                [ class Header
                    [ display block
                    , flex (int 0)
                    , width (px 150)
                    , children
                        [ class Head
                            [ width (px 150)
                            , height (px 150)
                            , borderRadius (pct 100)
                            ]
                        ]
                    ]
                , class Chat
                    [ flexContainerVert
                    , height (px 300)
                    , width (px 400)
                    , borderRadius (px 8)
                    , padding (px 0)
                    , backgroundColor Color.bgSelected
                    , children
                        [ ul
                            [ flex (int 1)
                            , overflowY auto
                            , margin (px 0)
                            , padding4 (px 0) (px 0) (px 6) (px 0)
                            , children
                                [ li
                                    [ display block
                                    , child span
                                        [ display inlineBlock
                                        , backgroundColor <| hex "ada"
                                        , borderRadius (px 4)
                                        , padding (px 8)
                                        ]
                                    , padding2 (px 2) (px 8)
                                    ]
                                , class To
                                    [ textAlign right
                                    , child span [ backgroundColor <| hex "aad" ]
                                    ]
                                , class Sys
                                    [ textAlign center
                                    , child span [ backgroundColor <| hex "aaa" ]
                                    ]
                                ]
                            ]
                        , div
                            [ flex (int 0)
                            , minHeight (px 42)
                            , textAlign center
                            , child span
                                [ border3 (px 2) solid (hex "ccc")
                                , borderRadius (px 8)
                                , padding (px 4)
                                , margin (px 4)
                                , display inlineBlock
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
