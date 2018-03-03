module Apps.LogViewer.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import UI.Common exposing (flexContainerHorz)
import UI.Icons as Icons
import Apps.LogViewer.Resources exposing (Classes(..), prefix)


ico : Style
ico =
    before
        [ Icons.fontFamily
        , textAlign center
        ]


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class ETop
            [ flexContainerHorz ]
        , class EBottom
            [ flexContainerHorz ]
        , class BtnUser
            [ ico
            , before [ Icons.user ]
            ]
        , class BtnEdit
            [ ico
            , before [ Icons.edit ]
            ]
        , class BtnHide
            [ ico
            , before [ Icons.view ]
            ]
        , class BtnFilter
            [ ico
            , before [ Icons.filter ]
            ]
        , class BtnCrypt
            [ ico
            , before [ Icons.lock ]
            ]
        , class BtnDelete
            [ ico
            , before [ Icons.trash ]
            ]
        , class BtnDecrypt
            [ ico
            , before [ Icons.unlock ]
            ]
        , class BtnApply
            [ ico
            , before [ Icons.apply ]
            ]
        , class BtnCancel
            [ ico
            , before [ Icons.cancel ]
            ]
        , class BottomButton
            [ cursor pointer ]
        , class IcoCrosshair
            [ ico
            , before [ Icons.locationTarget ]
            ]
        , class IcoDangerous
            [ ico
            , before [ Icons.dangerous ]
            ]
        , class BoxifyMe
            [ border3 (px 1) solid (hex "444")
            , padding (px 2)
            , display block
            , width (pct 100)
            ]
        ]
