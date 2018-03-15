module OS.WindowManager.Sidebar.Style exposing (..)

import Css exposing (..)
import Css.Colors as Colors
import Css.Namespace exposing (namespace)
import Utils.Css exposing (transition, Easing(..))
import OS.WindowManager.Sidebar.Resources exposing (..)
import UI.Colors as Colors


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Super
            [ flex (int 1)
            , width (px 320)
            , height (pct 100)
            , overflowY auto
            , marginRight (px -320)
            , transition 0.5 "margin-right" EaseInOut
            , withClass Visible [ marginRight (px 0) ]
            ]
        , class Toggler
            [ textShadow4 (px 1) (px 0) (px 3) Colors.black
            , color Colors.white
            , flex (int 0)
            ]
        , class Widget
            [ margin (px 8)
            , padding (px 8)
            , borderRadius (px 8)
            , border3 (px 1) solid Colors.black
            , backgroundColor (rgba 0 0 0 0.7)
            , fontSize (px 10)
            , color Colors.white
            ]
        ]
