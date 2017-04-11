module OS.WindowManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


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
            [ backgroundColor (hex "AAA")
            , position (absolute)
            ]
        , class WindowHeader
            [ displayFlex
            , flexFlow2 row wrap
            , backgroundColor (hex "888")
            ]
        , class HeaderTitle
            [ flex (int 0)
            , paddingLeft (px 8)
            ]
        , class HeaderVoid
            [ flex (int 1)
            ]
        , class HeaderButtons
            [ flex (int 0)
            , paddingRight (px 8)
            ]
        , class HeaderButton
            [ cursor pointer
            ]
        ]
