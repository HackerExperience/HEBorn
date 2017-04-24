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
    | BtnFilter
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
            , before [ Icon.user ]
            ]
        , class BtnEdit
            [ ico
            , before [ Icon.edit ]
            ]
        , class BtnView
            [ ico
            , before [ Icon.view ]
            ]
        , class BtnFilter
            [ ico
            , before [ Icon.filter ]
            ]
        , class BtnLock
            [ ico
            , before [ Icon.lock ]
            ]
        , class BtnDelete
            [ ico
            , before [ Icon.trash ]
            ]
        , class BtnUnlock
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
        , class CasedBtnExpand
            [ ico
            , before [ Icon.divExpand ]
            ]
        , class IcoCrosshair
            [ ico
            , before [ Icon.locationTarget ]
            ]
        , class IcoUser
            [ ico
            , before [ Icon.person ]
            ]
        , class IcoHome
            [ ico
            , before [ Icon.home ]
            ]
        ]
