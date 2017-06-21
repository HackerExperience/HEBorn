module UI.Layouts.VerticalList exposing (..)

import Html exposing (Html, node)


verticalList : List (Html msg) -> Html msg
verticalList entries =
    node "verticallist" [] entries
