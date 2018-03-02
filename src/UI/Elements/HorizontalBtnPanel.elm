module UI.Elements.HorizontalBtnPanel exposing (horizontalBtnPanel)

import Html exposing (Html, Attribute, node, span, text)
import Html.Events exposing (onClick)


btn : ( Attribute msg, msg ) -> Html msg
btn ( classes, clickCallback ) =
    span [ classes, onClick clickCallback ] []


horizontalBtnPanel : List ( Attribute msg, msg ) -> Html msg
horizontalBtnPanel btns =
    let
        data =
            btns
                |> List.map btn
                |> List.intersperse
                    (text " ")
    in
        node "horizontalBtnPanel" [] data
