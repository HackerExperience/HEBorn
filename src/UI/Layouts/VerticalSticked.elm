module UI.Layouts.VerticalSticked exposing (..)

import Html exposing (Html, node, header, footer)


verticalSticked : Maybe (List (Html msg)) -> List (Html msg) -> Maybe (List (Html msg)) -> Html msg
verticalSticked header_ main_ footer_ =
    node "verticalSticked"
        []
        [ node "headerStick" [] (Maybe.withDefault [] header_)
        , node "mainCont" [] main_
        , node "footerStick" [] (Maybe.withDefault [] footer_)
        ]
