module OS.SessionManager.WindowManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Utils exposing (pseudoContent, attrSelector)
import Css.Common exposing (globalShadow, flexContainerHorz, flexContainerVert, internalPadding)
import Css.Icons as Icon


type Class
    = Window
    | WindowHeader
    | WindowBody
    | Maximizeme
    | HeaderTitle
    | HeaderVoid
    | HeaderButtons
    | HeaderButton
    | HeaderBtnClose
    | HeaderBtnMaximize
    | HeaderBtnMinimize
    | HeaderContextSw


wmBorderRadius : Px
wmBorderRadius =
    (px 4)


css : Stylesheet
css =
    (stylesheet << namespace "wm")
        [ class Window
            [ position (absolute)
            , displayFlex
            , borderRadius wmBorderRadius
            , flexDirection column
            , globalShadow
            , flex (int 0)
            , withClass Maximizeme
                [ property "top" "auto !important"
                , property "left" "auto !important"
                , property "width" "100% !important"
                , property "height" "auto !important"
                , position relative
                , flex (int 1)
                , borderRadius (px 0)
                , children
                    [ class WindowBody
                        [ borderRadius (px 0) ]
                    , class WindowHeader
                        [ borderRadius (px 0) ]
                    ]
                ]
            ]
        , class WindowBody
            [ borderRadius4 (px 0) (px 0) wmBorderRadius wmBorderRadius
            , backgroundColor (hex "EEE")
            , flex (int 1)
            , overflowY hidden
            , flexContainerVert
            ]
        , class WindowHeader
            [ displayFlex
            , flexFlow2 row wrap
            , property "background" "linear-gradient(to bottom, #6c6c6c 0%,#4c4c4c 100%)"
            , color (hex "FFF")
            , flex (int 0)
            , borderRadius4 wmBorderRadius wmBorderRadius (px 0) (px 0)
            , internalPadding
            , lineHeight (px 16)
            , borderBottom3 (px 1) solid (rgb 0 140 255)
            , fontSize (px 12)
            ]
        , class HeaderTitle
            [ flex (int 1)
            , textAlign center
            , before
                [ Icon.fontFamily
                , minWidth (px 14)
                , textAlign center
                , float left
                ]
            ]
        , attrSelector "wmHeaderTitle"
            "data-icon"
            "="
            "explorer"
            [ before
                [ Icon.explorer ]
            ]
        , attrSelector "wmHeaderTitle"
            "data-icon"
            "="
            "logvw"
            [ before
                [ Icon.logvw ]
            ]
        , attrSelector "wmHeaderTitle"
            "data-icon"
            "="
            "browser"
            [ before
                [ Icon.browser ]
            ]
        , attrSelector "wmHeaderTitle"
            "data-icon"
            "="
            "taskmngr"
            [ before
                [ Icon.taskMngr ]
            ]
        , class HeaderButtons
            [ flex (int 0)
            , flexContainerHorz
            ]
        , class HeaderButton
            [ cursor pointer
            , flex (int 0)
            , minWidth (px 16)
            , margin2 (px 0) (px 4)
            , display inlineBlock
            , textAlign center
            , fontSize (px 16)
            , marginBottom (px -2)
            , color (hex "FFF")
            , before
                [ Icon.fontFamily
                , textAlign center
                ]
            ]
        , class HeaderBtnClose
            [ before
                [ Icon.windowClose ]
            ]
        , class HeaderBtnMaximize
            [ before
                [ Icon.windowMaximize ]
            ]
        , class HeaderBtnMinimize
            [ before
                [ Icon.windowMinimize ]
            ]
        , class HeaderContextSw
            [ margin2 (px 0) (px 8) ]
        ]
