module UI.Widgets.HorizontalBtnPanel exposing (horizontalBtnPanel)

import Html exposing (Html, Attribute, node, span, text)
import Html.Events exposing (onClick)


renderButton : ( Attribute msg, msg ) -> Html msg
renderButton ( classes, clickCallback ) =
    span [ classes, onClick clickCallback ] []


horizontalBtnPanel : List ( Attribute msg, msg ) -> Html msg
horizontalBtnPanel btns =
    let
        data =
            btns
                |> List.map renderButton
                |> List.intersperse
                    (text " ")
    in
        node "horizontalBtnPanel" [] data
