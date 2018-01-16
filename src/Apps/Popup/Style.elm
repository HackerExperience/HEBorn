module Apps.Popup.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Apps.Popup.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class PopupMessage
            []
        , class PopupInteraction
            [ displayFlex
            , alignItems flexEnd
            ]
        ]
