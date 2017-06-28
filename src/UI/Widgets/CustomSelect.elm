module UI.Widgets.CustomSelect exposing (customSelect)

import Html exposing (Html, node, text)
import Html.Attributes exposing (attribute)
import Html.Events exposing (onClick)


option : (comparable -> msg) -> comparable -> ( comparable, Html msg ) -> Html msg
option callback active ( selector, value ) =
    let
        selected =
            if selector == active then
                "1"
            else
                "0"
    in
        node "customOption"
            [ attribute "selected" selected
            , onClick (callback selector)
            ]
            [ value ]


customSelect : msg -> (comparable -> msg) -> comparable -> List ( comparable, Html msg ) -> Html msg
customSelect menuAction callback active options =
    let
        childs =
            options |> (List.map <| option callback active)
    in
        node "customSelect"
            [ onClick menuAction ]
            childs
