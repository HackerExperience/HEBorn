module UI.Layouts.VerticalList exposing (..)

import Html


verticalList : List (Html msg) -> Html msg
verticalList entries =
    node "verticallist" [] entries
