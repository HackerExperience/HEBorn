module UI.Layouts.FlexColumns exposing (..)

import Html exposing (Html, node)


flexCols : List (Html msg) -> Html msg
flexCols entries =
    node "flexcols" [] entries
