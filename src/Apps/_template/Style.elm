module Apps.Template.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Apps.Template.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Todo
            []
        ]
