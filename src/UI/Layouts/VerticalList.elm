module UI.Layouts.VerticalList exposing (..)

import Html exposing (Html, Attribute, node)


verticalList : List (Attribute msg) -> List (Html msg) -> Html msg
verticalList attr entries =
    node "verticallist" attr entries
