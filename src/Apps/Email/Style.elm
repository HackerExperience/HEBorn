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
        [ class Contacts
            [ flex (int 0)
            , overflowY auto
            , overflowX hidden
            , listStyle none
            , padding (px 0)
            , children
                [ li
                    [ padding2 (px 22) (px 8) ]
                , class Avatar
                    [ width (px 48)
                    , height (px 48)
                    , borderRadius (pct 100)
                    ]
                ]
            ]
        ]
