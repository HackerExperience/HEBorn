module UI.Layouts.VerticalList exposing (..)

import Html exposing (Html, node)
import Css exposing (overflowY, scroll)
import Css.Utils exposing (styles)


verticalList : List (Html msg) -> Html msg
verticalList entries =
    let
        attr =
            styles [ overflowY scroll ]
                |> List.singleton
    in
        node "verticallist" attr entries
