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
            [ display block
            , width (pct 100)
            , children
                [ class Contacts
                    [ flex (int 0)
                    , overflowY auto
                    , overflowX hidden
                    , width (pct 100)
                    , listStyle none
                    , padding (px 0)
                    , children
                        [ li
                            [ padding2 (px 22) (px 8) ]
                        ]
                    ]
                ]
            ]
        ]
