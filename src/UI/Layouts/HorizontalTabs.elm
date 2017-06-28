module UI.Layouts.HorizontalTabs exposing (horizontalTabs)

import Html exposing (Html, node, text)
import Html.Attributes exposing (attribute)
import Html.Events exposing (onClick)


selectedAttr : Bool -> Html.Attribute msg
selectedAttr enabled =
    let
        value =
            if enabled then
                "1"
            else
                "0"
    in
        attribute "data-selected" value


tabBtn : (comparable -> msg) -> ( comparable, String, Bool ) -> Html msg
tabBtn callback ( key, label, selected ) =
    node "tab"
        [ selectedAttr selected
        , onClick (callback key)
        ]
        [ text label ]


tabPainel : (comparable -> msg) -> List ( comparable, String, Bool ) -> Html msg
tabPainel callback tabs =
    node
        "panel"
        []
        (List.map (tabBtn callback) tabs)


markSelected : Int -> List ( comparable, String ) -> List ( comparable, String, Bool )
markSelected active =
    List.indexedMap
        (\i ( k, v ) -> ( k, v, i == active ))


horizontalTabs : Html msg -> Int -> List ( comparable, String ) -> (comparable -> msg) -> Html msg
horizontalTabs entry active tabs callback =
    node "horizontalTabs"
        []
        [ tabs |> markSelected active |> tabPainel callback
        , entry
        ]
