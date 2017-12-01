module Apps.LogFlix.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Common exposing (flexContainerHorz)
import Css.Icons as Icon
import Apps.LogFlix.Resources exposing (Classes(..), prefix)


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
                            [ color (hex "0000FF") ]
                        , class BFReceive
                            [ color (hex "00FFFF") ]
                        , class BFJoin
                            [ color (hex "00FF00") ]
                        , class BFJoinAccount
                            [ color (hex "00FF00") ]
                        , class BFJoinServer
                            [ color (hex "0000FF") ]
                        , class BFOther
                            [ color (hex "777777") ]
                        , class BFNone
                            [ color (hex "333333") ]
                        , class BFEvent
                            [ color (hex "999900") ]
                        , class BFError
                            [ color (hex "FF0000") ]
                        ]
                    ]
                , class DataDiv
                    [ border3 (px 1) solid (hex "000000")
                    ]
                ]
            ]
        ]
