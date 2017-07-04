module Apps.ConnManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Icons as Icon


type Classes
    = IcoUp
    | IcoDown
    | GroupedTunnel


prefix : String
prefix =
    "connmngr"


ico : Style
ico =
    before
        [ Icon.fontFamily
        , textAlign center
        ]


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class IcoUp
            [ ico
            , before [ Icon.upload ]
            ]
        , class IcoDown
            [ ico
            , before [ Icon.download ]
            ]
        ]
