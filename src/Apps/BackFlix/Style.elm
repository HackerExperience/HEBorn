module Apps.BackFlix.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Common exposing (flexContainerHorz)
import Css.Icons as Icon
import Css.Colors as Colors
import Apps.BackFlix.Resources exposing (Classes(..), prefix)


ico : Style
ico =
    before
        [ Icon.fontFamily
        , textAlign center
        ]


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class LogBox
            [ padding (px 10)
            , displayFlex
            , flexDirection row
            , flexWrap wrap
            , children
                [ class LogHeader
                    [ width (pct 100)
                    , displayFlex
                    , justifyContent spaceBetween
                    , children
                        [ class BFRequest
                            [ color Colors.blue ]
                        , class BFReceive
                            [ color Colors.yellow ]
                        , class BFJoin
                            [ color Colors.lime ]
                        , class BFJoinAccount
                            [ color Colors.green ]
                        , class BFJoinServer
                            [ color Colors.maroon ]
                        , class BFOther
                            [ color Colors.gray ]
                        , class BFNone
                            [ color Colors.silver ]
                        , class BFEvent
                            [ color Colors.orange ]
                        , class BFError
                            [ color Colors.red ]
                        ]
                    ]
                , class DataDiv
                    [ border3 (px 1) solid Colors.black
                    ]
                ]
            ]
        ]
