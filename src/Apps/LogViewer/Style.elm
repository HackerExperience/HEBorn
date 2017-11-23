module Apps.LogViewer.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Common exposing (flexContainerHorz)
import Css.Icons as Icon
import Apps.LogViewer.Resources exposing (Classes(..), prefix)


ico : Style
ico =
    before
        [ Icon.fontFamily
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
            , before [ Icon.user ]
            ]
        , class BtnEdit
            [ ico
            , before [ Icon.edit ]
            ]
        , class BtnHide
            [ ico
            , before [ Icon.view ]
            ]
        , class BtnFilter
            [ ico
            , before [ Icon.filter ]
            ]
        , class BtnCrypt
            [ ico
            , before [ Icon.lock ]
            ]
        , class BtnDelete
            [ ico
            , before [ Icon.trash ]
            ]
        , class BtnDecrypt
            [ ico
            , before [ Icon.unlock ]
            ]
        , class BtnApply
            [ ico
            , before [ Icon.apply ]
            ]
        , class BtnCancel
            [ ico
            , before [ Icon.cancel ]
            ]
        , class BottomButton
            [ cursor pointer ]
        , class IcoCrosshair
            [ ico
            , before [ Icon.locationTarget ]
            ]
        , class IcoDangerous
            [ ico
            , before [ Icon.dangerous ]
            ]
        , class BoxifyMe
            [ border3 (px 1) solid (hex "444")
            , padding (px 2)
            , display block
            , width (pct 100)
            ]
        ]
