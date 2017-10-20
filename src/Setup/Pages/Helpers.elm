module Setup.Pages.Helpers exposing (withHeader)

import Html exposing (..)
import Html.CssHelpers
import Setup.Resources exposing (..)


withHeader : List (Html.Attribute msg) -> Html msg -> Html msg
withHeader attrs content =
    node contentNode
        attrs
        [ div [] [ h1 [] [ text " D'LayDOS" ] ]
        , content
        ]
