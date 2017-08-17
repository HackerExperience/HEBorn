module Apps.Email.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Apps.Email.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Todo
            []
        ]
