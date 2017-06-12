module Apps.LogViewer.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (input, span)
import Css.Common exposing (internalPadding, internalPaddingSz, flexContainerHorz)
import Css.Icons as Icon


type Classes
    = HeaderBar
    | Entry
    | EntryExpanded
    | ETop
    | ETAct
    | ETActMini
    | ETFilter
    | ETFBar
    | EData
    | EAct
    | EBottom
    | EToggler
    | BtnUser
    | BtnEdit
    | BtnHide
    | BtnFilter
    | BtnCrypt
    | BtnDelete
    | BtnUnlock
    | BtnApply
    | BtnCancel
    | BottomButton
    | CasedBtnExpand
    | IcoCrosshair
    | IcoUser
    | IcoHome
    | IcoDangerous
    | IdMe
    | IdOther
    | IdLocal
    | IdRoot
    | ColorLocal
    | ColorRoot
    | ColorRemote
    | ColorDangerous
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
    (stylesheet << namespace "logvw")
        [ class HeaderBar
            [ flexContainerHorz
            , borderBottom3 (px 1) solid (hex "000")
            , internalPadding
            ]
        , class ETAct
            [ flex (int 1)
            , fontSize (px 32)
            ]
        , class ETFilter
            [ flex (int 0)
            , flexContainerHorz
            , lineHeight (px 32)
            ]
        , class ETFBar
            [ children
                [ input
                    [ flex (int 1)
                    , marginLeft (px 18)
                    , padding (px 3)
                    , borderRadius (px 12)
                    , border3 (px 1) solid (hex "000")
                    ]
                ]
            ]
        , class ETop
            [ flexContainerHorz ]
        , class EBottom
            [ flexContainerHorz ]
        , class Entry
            [ fontSize (px 12)
            , borderBottom3 (px 1) solid (hex "000")
            , padding (px 16)
            , internalPadding
            ]
        , class EAct
            [ width (pct 100)
            , fontSize (px 24)
            , textAlign center
            ]
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
            , cursor pointer
            ]
        , class BottomButton
            [ cursor pointer ]
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
        , class IcoDangerous
            [ ico
            , before [ Icon.dangerous ]
            ]
        , class IdMe
            [ textDecoration underline
            ]
        , class IdLocal
            [ fontWeight bold
            ]
        , class IdOther
            [ color (hex "C04839")
            , textDecoration underline
            ]
        , class ColorLocal
            [ color (hex "56822E") ]
        , class ColorRoot
            [ color (hex "9B9E5B") ]
        , class ColorRemote
            [ color (hex "00E") ]
        , class ColorDangerous
            [ color (hex "C04839") ]
        , class BoxifyMe
            [ border3 (px 1) solid (hex "444")
            , padding (px 2)
            , display block
            , width (pct 100)
            ]
        , class EntryExpanded
            [ children
                [ class EBottom
                    [ children
                        [ class CasedBtnExpand
                            [ before [ Icon.divContract ] ]
                        ]
                    ]
                ]
            ]
        ]
