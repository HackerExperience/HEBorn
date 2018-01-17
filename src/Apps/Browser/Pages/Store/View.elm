module Apps.Browser.Pages.Store.View exposing (view)

import Html exposing (Html, div, text)


view : Html msg
view =
    div []
        [ storeHeader
        , storeItems
        , storeFooter
        ]


storeHeader : Model -> Html msg
storeHeader model =
    div [] [ text "footer" ]


storeItems : Model -> Html msg
storeItems model =
    div [] [ text "items" ]


storeFooter : Model -> Html msg
storeFooter model =
    div [] [ text "footer" ]
