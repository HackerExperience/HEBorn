module UI.Widgets.Popup
    exposing
        ( popup
        , popupOkCancel
        , popupNode
        , overlayNode
        )

import Html exposing (Html, Attribute, node, div, button, text)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Utils.Html.Attributes exposing (dataDecorated)
import OS.SessionManager.WindowManager.Resources exposing (..)


-- example usage: `popup "Are you sure?" []`


wmClass : List class -> Attribute msg
wmClass =
    .class <| Html.CssHelpers.withNamespace prefix


popupOkCancel : String -> msg -> msg -> Html msg
popupOkCancel content ok cancel =
    popup content [ ( ok, "Ok" ), ( cancel, "Cancel" ) ]


popup : String -> List ( msg, String ) -> Html msg
popup content buttons =
    let
        title_ =
            div [] [ div [ wmClass [ WindowHeader ] ] [] ]

        buttons_ =
            let
                reducer ( action, content ) buttons =
                    button [ onClick action ] [ text content ] :: buttons
            in
                List.foldr reducer [] buttons

        content_ =
            div [ wmClass [ WindowBody ] ] (text content :: buttons_)

        window =
            div [ wmClass [ Window ], dataDecorated True ] [ title_, content_ ]

        root =
            node popupNode [] [ overlay, window ]
    in
        root


overlay : Html msg
overlay =
    node overlayNode [] []


popupNode : String
popupNode =
    "popup"


overlayNode : String
overlayNode =
    "overlay"
