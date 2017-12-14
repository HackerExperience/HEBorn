module Setup.Pages.Helpers exposing (withHeader)

import Html exposing (..)
import Setup.Resources exposing (..)


withHeader : List (Html.Attribute msg) -> List (Html msg) -> Html msg
withHeader attrs content =
    node contentNode attrs <|
        flip (::) content <|
            div [] [ h1 [] [ text " D'LayDOS" ] ]
