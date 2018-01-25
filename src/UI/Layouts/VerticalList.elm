module UI.Layouts.VerticalList exposing (..)

import Html exposing (Html, Attribute, node)


verticalList : List (Html msg) -> Html msg
verticalList entries =
    node "verticallist" [] entries


verticalListWithAttr : List (Attribute msg) -> List (Html msg) -> Html msg
verticalListWithAttr attr entries =
    node "verticallist" attr entries
