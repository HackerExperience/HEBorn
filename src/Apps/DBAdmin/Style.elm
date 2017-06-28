module Apps.DBAdmin.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Common exposing (flexContainerHorz)
import Css.Icons as Icon


type Classes
    = ETop
    | EBottom
    | BtnEdit
    | BtnFilter
    | BtnDelete
    | BtnApply
    | BtnCancel
    | BottomButton
    | BoxifyMe


ico : Mixin
ico =
    mixin
        [ before
            [ Icon.fontFamily
            , textAlign center
            ]
        ]


css : Stylesheet
css =
    (stylesheet << namespace "udb")
        [ class ETop
            [ flexContainerHorz ]
        , class EBottom
            [ flexContainerHorz ]
        , class BtnEdit
            [ ico
            , before [ Icon.edit ]
            ]
        , class BtnFilter
            [ ico
            , before [ Icon.filter ]
            ]
        , class BtnDelete
            [ ico
            , before [ Icon.trash ]
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
        , class BoxifyMe
            [ border3 (px 1) solid (hex "444")
            , padding (px 2)
            , display block
            , width (pct 100)
            ]
        ]
