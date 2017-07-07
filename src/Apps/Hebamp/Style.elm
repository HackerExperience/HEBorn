module Apps.Hebamp.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Colors exposing (black, lime)
import Css.FontAwesome.Helper exposing (fontAwesome, faIcon)
import Css.FontAwesome.Icons as FA
import Apps.Hebamp.Resources exposing (Classes(..), prefix)


-- Based on this: https://codepen.io/pedox/pen/ndpfD


white : Color
white =
    hex "FFF"


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Container
            [ fontFamilies [ "Arial" ]
            , display block
            , width (px 275)
            , border3 (px 2) ridge (hex "7e7e7e")
            , backgroundImage <|
                linearGradient2 toLeft
                    (stop2 (hex "1a1927") (pct 0))
                    (stop2 (hex "353551") (pct 53))
                    [ (stop2 (hex "21212d") (pct 100)) ]
            ]
        , class Player
            [ margin (px 3)
            , marginTop (px 0)
            , height (px 103)
            , border3 (px 3) groove (hex "7e7e7e")
            ]
        , class Header
            [ fontWeight bold
            , color (hex "fff")
            , fontSize (px 10)
            , textAlign center
            , before
                [ backgroundImage <|
                    linearGradient2 toTop
                        (stop2 (hex "fffcdf") (pct 0))
                        (stop2 (hex "fffcdf") (pct 29))
                        [ (stop2 (hex "736c50") (pct 32))
                        , (stop2 (hex "736c50") (pct 66))
                        , (stop2 (hex "d5ceb1") (pct 69))
                        , (stop2 (hex "d5ceb1") (pct 100))
                        ]
                , property "content" "\"\""
                , height (px 8)
                , width (px 266)
                , display block
                , marginTop (px 2)
                , marginLeft (px 5)
                , position absolute
                , zIndex (int 0)
                ]
            , after
                [ property "content" "\"HEBAMP\""
                , display block
                , marginTop (px -12)
                , marginLeft (px 110)
                , position absolute
                , backgroundColor (hex "353551")
                , padding (px 0)
                , width (px 55)
                ]
            ]
        , class Vis
            [ float left
            , width (px 89)
            , height (px 42)
            , margin4 (px 8) (px 3) (px 3) (px 5)
            , padding4 (px 3) (px 3) (px 0) (px 0)
            , border3 (px 1) inset (hex "69667b")
            , backgroundColor (hex "0f0f0f")
            , fontFamilies [ "monospace" ]
            , fontSize (px 15)
            , color lime
            , textAlign right
            ]
        , class Title
            [ float left
            , width (px 150)
            , height (px 12)
            , marginLeft (px 3)
            , textAlign left
            , fontSize (px 9)
            , textIndent (px 5)
            ]
        , class Inf
            [ border3 (px 1) inset (hex "69667B")
            , width (px 15)
            , height (px 10)
            , backgroundColor (hex "0F0F0F")
            , float left
            , marginLeft (px 3)
            , marginTop (px 2)
            , marginRight (px 25)
            , after
                [ property "content" "\"Kbps\""
                , fontSize (px 8)
                , marginLeft (px 20)
                , color white
                , fontWeight bold
                , position absolute
                ]
            ]
        , class KHz
            [ after [ property "content" "\"Khz\"" ] ]
        , class MonoStereo
            [ float right
            , color white
            , fontSize (px 8)
            , fontWeight bold
            , marginRight (px 4)
            , marginTop (px 4)
            , after
                [ marginLeft (px 5)
                , textShadow4 (px 0) (px 0) (px 6) (hex "00ff0f")
                , color (hex "20ff17")
                , property "content" "\"stereo\""
                ]
            ]
        , class Bar
            [ backgroundColor (hex "C51B1E")
            , height (px 7)
            , width (px 64)
            , float left
            , marginLeft (px 3)
            , marginTop (px 5)
            , boxShadow5 inset (px 0) (px 0) (px 4) black
            , borderRadius (px 2)
            , borderBottom3 (px 1) solid (hex "858585")
            , after
                [ property "content" "\"III\""
                , backgroundColor (hex "BBB")
                , fontSize (px 6)
                , padding2 (px 0) (px 2)
                , marginTop (px -1)
                , position absolute
                , border3 (px 2) outset white
                , fontWeight bold
                , boxShadow5 (px 0) (px 0) (px 0) (px 1) black
                ]
            ]
        , class Balanced
            [ width (px 30)
            , marginLeft (px 6)
            , backgroundColor (hex "358A23")
            , after
                [ marginLeft (px 8) ]
            ]
        , class Volume
            [ after
                [ marginLeft (px 50) ]
            ]
        , class Btn
            [ backgroundColor (hex "BBB")
            , fontSize (px 6)
            , padding4 (px 0) (px 1) (px 0) (px 7)
            , border3 (px 2) outset white
            , fontWeight bold
            , float left
            , color (hex "333")
            , marginTop (px 4)
            , marginLeft (px 1)
            ]
        , class Ext
            [ before
                [ property "content" "\"\""
                , display block
                , width (px 3)
                , height (px 3)
                , backgroundColor (hex "686868")
                , position absolute
                , marginLeft (px -5)
                , marginTop (px 1)
                ]
            ]
        , class Left
            [ marginLeft (px 9) ]
        , class Slidebar
            [ border3 (px 2) inset (hex "7E7E7E")
            , float left
            , height (px 8)
            , width (px 252)
            , margin (px 5)
            , marginTop (px 5)
            , children
                [ class Pointer
                    [ backgroundImage <|
                        linearGradient2 toTop
                            (stop2 (hex "fffcdf") (pct 0))
                            (stop2 (hex "fffcdf") (pct 29))
                            [ stop2 (hex "736c50") (pct 32)
                            , stop2 (hex "736c50") (pct 66)
                            , stop2 (hex "d5ceb1") (pct 69)
                            , stop2 (hex "d5ceb1") (pct 100)
                            ]
                    , width (px 25)
                    , height (px 4)
                    , display block
                    , property "content" "\"\""
                    , position absolute
                    , marginTop (px -2)
                    , border3 (px 4) ridge (hex "FCFFBD")
                    ]
                ]
            ]
        , class PlayerB
            [ fontSize (px 13)
            , padding4 (px 0) (px 7) (px 6) (px 7)
            , height (px 10)
            , width (px 6)
            , color (hex "7A7A7A")
            , textShadow4 (px 1) (px 1) (px 0) white
            , margin2 (px 0) (px 1)
            ]
        , class First
            [ marginLeft (px 7) ]
        , class Icon
            [ before [ fontAwesome ] ]
        , class IconStepBackward
            [ before [ faIcon FA.stepBackward ] ]
        , class IconStepForward
            [ before [ faIcon FA.stepForward ] ]
        , class IconPlay
            [ before [ faIcon FA.play ] ]
        , class IconStop
            [ before [ faIcon FA.stop ] ]
        , class IconPause
            [ before [ faIcon FA.pause ] ]
        , class IconEject
            [ before [ faIcon FA.eject ] ]
        ]
