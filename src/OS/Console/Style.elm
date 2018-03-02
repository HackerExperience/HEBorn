module OS.Console.Style exposing (..)

import Css exposing (..)
import Css.Common exposing (flexContainerVert, flexContainerHorz, globalShadow)
import Css.Elements exposing (typeSelector, ul, li, div, h6)
import Css.Namespace exposing (namespace)
import Css.Utils as Css exposing (..)
import Css.Icons as Icons
import UI.Style exposing (clickableBox)
import UI.Colors as Colors
import Css.Colors
import OS.Console.Resources exposing (..)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class LogConsole
            [ width (pct 100)
            , marginTop (px 41)
            , flexContainerVert
            , position absolute
            , zIndex (int -1)
            , backgroundColor (rgba 0 0 0 0.5)
            , color (hex "00FF00")
            , fontFamily monospace
            , fontFamilies [ "Monospace" ]
            , children
                [ div
                    [ children
                        [ consoleHeader
                        ]
                    ]
                ]
            ]
        ]


consoleHeader : Snippet
consoleHeader =
    class LogConsoleHeader
        [ justifyContent spaceBetween
        , children
            [ class BFRequest
                [ color Css.Colors.blue ]
            , class BFReceive
                [ color Css.Colors.yellow ]
            , class BFJoin
                [ color Css.Colors.lime ]
            , class BFJoinAccount
                [ color Css.Colors.green ]
            , class BFJoinServer
                [ color Css.Colors.maroon ]
            , class BFOther
                [ color Css.Colors.gray ]
            , class BFNone
                [ color Css.Colors.silver ]
            , class BFEvent
                [ color Css.Colors.orange ]
            , class BFError
                [ color Css.Colors.red ]
            ]
        ]
