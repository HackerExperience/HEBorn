module UI.Entries.Toogable exposing (toogableEntry)

import Html exposing (Html, Attribute, node, div)
import Html.Attributes exposing (attribute)
import Html.Events exposing (onClick)


expandedClass : Bool -> Html.Attribute msg
expandedClass enabled =
    let
        value =
            if enabled then
                "1"
            else
                "0"
    in
        attribute "data-expanded" value


toogleBtn : msg -> Bool -> Html msg
toogleBtn callback actualState =
    node "btn"
        [ expandedClass actualState
        , onClick callback
        ]
        []


toogableEntry : Bool -> List (Attribute msg) -> msg -> Bool -> List (Html msg) -> Html msg
toogableEntry toogableVisible attrs callback actualState data =
    node
        "toogableEntry"
        attrs
        [ node "content" [] data
        , if toogableVisible then
            toogleBtn callback actualState
          else
            div [] []
        ]
