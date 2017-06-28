module UI.Layouts.HorizontalTabs exposing (horizontalTabs)

import Html exposing (Html, node, text)
import Html.Attributes exposing (attribute)
import Html.Events exposing (onClick)
import UI.Layouts.VerticalSticked exposing (verticalSticked)


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


tab : (comparable -> msg) -> ( comparable, Html msg, Bool ) -> Html msg
tab callback ( key, content, selected ) =
    node "tab"
        [ selectedAttr selected
        , onClick (callback key)
        ]
        [ content ]


tabPainel : (comparable -> msg) -> List ( comparable, Html msg, Bool ) -> Html msg
tabPainel callback tabs =
    node
        "panel"
        []
        (List.map (tab callback) tabs)


markSelected : Int -> List ( comparable, Html msg ) -> List ( comparable, Html msg, Bool )
markSelected active =
    List.indexedMap
        (\i ( k, v ) -> ( k, v, i == active ))


horizontalTabs : List (Html msg) -> Int -> List ( comparable, Html msg ) -> (comparable -> msg) -> Html msg
horizontalTabs entries active tabs callback =
    verticalSticked
        (Just [ tabs |> markSelected active |> tabPainel callback ])
        entries
        Nothing
