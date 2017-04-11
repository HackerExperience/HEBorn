module OS.WindowManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Utils exposing (globalShadow)


type Css
    = Window
    | WindowHeader
    | HeaderTitle
    | HeaderVoid
    | HeaderButtons
    | HeaderButton
    | WindowBody


css : Stylesheet
css =
    (stylesheet << namespace "wm")
        [ class Window
            [  position (absolute)
            , displayFlex
            , borderRadius4 (px 8) (px 8) (px 8) (px 8)
            , flexDirection column
            , globalShadow
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
            -- , backgroundColor (hex "888")
            , property "background" "linear-gradient(to bottom, #606c88 0%,#3f4c6b 100%)"
            , color (hex "FFF")
            , flex (int 0)
            , borderRadius4 (px 8) (px 8) (px 0) (px 0)
            , padding (px 8)
            , lineHeight (int 1)
            ]
        , class HeaderTitle
            [ flex (int 1)
            , textAlign center
            ]
        , class HeaderButtons
            [ flex (int 0) ]
        , class HeaderButton
            [ cursor pointer
            ]
        ]
