module Apps.LocationPicker.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Common exposing (flexContainerHorz)
import Apps.LocationPicker.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Super
            [ height (pct 100)
            , display block
            , flexContainerHorz
            ]
        , class Map
            [ width auto
            , flex (int 1)
            ]
        , class Interactive
            [ minWidth (px 200)
            , flex (int 0)
            ]
        ]
