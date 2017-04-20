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


css : Stylesheet
css =
    (stylesheet << namespace "logvw")
        [ class HeaderBar
            []
        ]
