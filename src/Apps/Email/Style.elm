module Apps.Email.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (ul, li, span)
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
                    , overflowY auto
                    , padding (px 8)
                    , height (pct 100)
                    , backgroundColor Color.bgSelected
                    , displayFlex
                    , child ul
                        [ padding (px 0)
                        , flex (int 1)
                        , alignSelf flexEnd
                        , children
                            [ li
                                [ display block
                                , child span
                                    [ backgroundColor <| hex "ada"
                                    , borderRadius (px 4)
                                    , padding (px 8)
                                    ]
                                , margin2 (px 22) (px 8)
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
                    ]
                ]
            ]
        ]
