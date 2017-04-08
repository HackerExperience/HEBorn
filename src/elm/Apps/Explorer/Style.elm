module Apps.Explorer.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


type Classes
    = Window
    | Nav
    | Content


css : Stylesheet
css =
    (stylesheet << namespace "explorer")
    [ class Window
        [ displayFlex
        , flexFlow2 row noWrap
        ]
    , class Nav
        [ margin zero
        , padding zero
        , flex (int 1)
        ]
    , class Content
        [ flex (int 3)
        ]
    ]
