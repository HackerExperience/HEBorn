module OS.WindowManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Utils exposing (pseudoContent, attrSelector)
import Css.Common exposing (globalShadow, flexContainerHorz)
import Css.FontAwesome.Helper exposing (fontAwesome, faIcon)
import Css.FontAwesome.Icons as FA exposing (..)

type Css
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


css : Stylesheet
css =
    (stylesheet << namespace "wm")
        [ class Window
            [  position (absolute)
            , displayFlex
            , borderRadius4 (px 8) (px 8) (px 8) (px 8)
            , flexDirection column
            , globalShadow
            , withClass Maximizeme
                [ property "transform" "none !important"
                , property "width" "100% !important"
                , property "height" "100% !important"
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
            [ borderRadius4 (px 0) (px 0) (px 8) (px 8)
            , backgroundColor (hex "EEE")
            , flex (int 1)
            , padding (px 8)
            ]
        , class WindowHeader
            [ displayFlex
            , flexFlow2 row wrap
            , property "background" "linear-gradient(to bottom, #6c6c6c 0%,#4c4c4c 100%)"
            , color (hex "FFF")
            , flex (int 0)
            , borderRadius4 (px 8) (px 8) (px 0) (px 0)
            , padding (px 8)
            , lineHeight (px 16)
            , borderBottom3 (px 1) solid (rgb 0 140 255)
            , fontSize (px 12)
            ]
        , class HeaderTitle
            [ flex (int 1)
            , textAlign center
            , before
                [ fontAwesome
                , minWidth (px 14)
                , textAlign center
                , float left
                ]
            ]
        , attrSelector "wmHeaderTitle" "data-icon" "=" "signup"
            [before
                [ faIcon FA.addressBookO ]
            ]
        , attrSelector "wmHeaderTitle" "data-icon" "=" "explorer"
            [before
                [ faIcon FA.fileArchiveO ]
            ]
        , class HeaderButtons
            [ flex (int 0)
            , flexContainerHorz ]
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
                [ fontAwesome
                , textAlign center
                ]
            ]
        , class HeaderBtnClose
            [ before
                [ faIcon FA.timesCircle ]
            ]
        , class HeaderBtnMaximize
            [ before
                [ faIcon FA.expand ]
            ]
        ]
