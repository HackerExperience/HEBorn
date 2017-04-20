module Apps.LogViewer.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


--import Css.Utils exposing (transition, easingToString, Easing(..), pseudoContent, selectableText)

import Css.Common exposing (internalPadding, internalPaddingSz)
import Css.Icons as Icon


type Classes
    = HeaderBar
    | Entry
    | ETop
    | ETAct
    | EData
    | EAct
    | EToggler
    | BtnUser
    | BtnEdit
    | BtnView
    | BtnOrder
    | BtnLock
    | BtnDelete
    | BtnUnlock
    | BtnApply
    | BtnCancel
    | CasedBtnExpand
    | IcoCrosshair
    | IcoUser
    | IcoHome


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
    (stylesheet << namespace "logvw")
        [ class HeaderBar
            []
        , class BtnUser
            [ ico
            , before [ Icon.fileGeneric ]
            ]
        , class BtnEdit
            [ ico
            , before [ Icon.fileGeneric ]
            ]
        , class BtnView
            [ ico
            , before [ Icon.fileGeneric ]
            ]
        , class BtnOrder
            [ ico
            , before [ Icon.fileGeneric ]
            ]
        , class BtnLock
            [ ico
            , before [ Icon.fileGeneric ]
            ]
        , class BtnDelete
            [ ico
            , before [ Icon.fileGeneric ]
            ]
        , class BtnUnlock
            [ ico
            , before [ Icon.fileGeneric ]
            ]
        , class BtnApply
            [ ico
            , before [ Icon.fileGeneric ]
            ]
        , class BtnCancel
            [ ico
            , before [ Icon.fileGeneric ]
            ]
        , class CasedBtnExpand
            [ ico
            , before [ Icon.fileGeneric ]
            ]
        , class IcoCrosshair
            [ ico
            , before [ Icon.fileGeneric ]
            ]
        , class IcoUser
            [ ico
            , before [ Icon.fileGeneric ]
            ]
        , class IcoHome
            [ ico
            , before [ Icon.fileGeneric ]
            ]
        ]
