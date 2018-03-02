module Apps.Email.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (ul, li, div, span)
import Utils.Css exposing (..)
import UI.Common exposing (..)
import UI.Colors as Colors
import Apps.Email.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Contacts
            [ flex (int 0)
            , overflowY auto
            , overflowX hidden
            , listStyle none
            , padding (px 0)
            , children
                [ li
                    [ padding2 (px 22) (px 8)
                    , children
                        [ class Avatar
                            [ width (px 48)
                            , height (px 48)
                            , borderRadius (pct 100)
                            ]
                        ]
                    ]
                ]
            ]
        ]
