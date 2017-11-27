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
                    ]
                , class DataDiv
                    [ border3 (px 1) solid (hex "000000")
                    ]
                ]
            ]
        ]
