module Apps.Email.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (ul, li, div, span)
import Css.Utils exposing (..)
import Css.Common exposing (..)
import UI.Colors as Color
import Apps.Email.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Super
            [ flexContainerHorz
            , height (pct 100)
            , children
                [ class Contacts
                    [ flex (int 0)
                    , minWidth (px 140)
                    , overflowY auto
                    , listStyle none
                    , padding (px 0)
                    , children
                        [ li
                            [ padding2 (px 22) (px 8) ]
                        , class Active
                            [ backgroundColor Color.bgSelected ]
                        ]
                    ]
                , class MainChat
                    [ flex (int 1)
                    , flexContainerVert
                    , height (pct 100)
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
