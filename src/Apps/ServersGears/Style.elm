module Apps.ServersGears.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Apps.ServersGears.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Todo
            []
        ]
