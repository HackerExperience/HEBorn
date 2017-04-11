module OS.WindowManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Utils exposing (globalShadow, pseudoContent)


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
                [ fontFamilies ["FontAwesome"]
                , minWidth (px 14)
                , textAlign center
                , float left
                ]
            ]
        , selector ".wmHeaderTitle[data-icon^=icon]"
            [before
                [ pseudoContent "\"\\f179\"" ]
            ]
        , class HeaderButtons
            [ flex (int 0) ]
        , class HeaderButton
            [ cursor pointer
            , color (hex "5c5c5c")
            , minWidth (px 16)
            , margin2 (px 0) (px 4)
            , display inlineBlock
            , backgroundColor (hex "FFF")
            , textAlign center
            , borderRadius (pct 100)
            ]
        ]
