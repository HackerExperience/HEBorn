module Apps.DBAdmin.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Utils.Css exposing (selectableText)
import UI.Common exposing (flexContainerHorz)
import UI.Icons as Icons
import Apps.DBAdmin.Resources exposing (Classes(..), prefix)


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
        , class BtnEdit
            [ ico
            , before [ Icons.edit ]
            ]
        , class BtnFilter
            [ ico
            , before [ Icons.filter ]
            ]
        , class BtnDelete
            [ ico
            , before [ Icons.trash ]
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
        , class FinanceEntry
            [ displayFlex
            , padding2 (px 4) (px 6)
            , children
                [ everything
                    [ display block ]
                , class RightSide
                    []
                , class LeftSide
                    [ alignSelf flexStart
                    , flex (int 1)
                    ]
                ]
            ]
        , class BoxifyMe
            [ border3 (px 1) solid (hex "444")
            , padding (px 2)
            , display block
            , width (pct 100)
            ]
        , class Password
            [ selectableText ]
        ]
