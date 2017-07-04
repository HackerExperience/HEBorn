module UI.Widgets.CustomSelect exposing (customSelect)

import Dict exposing (Dict)
import Html exposing (Html, node, text)
import Html.Attributes exposing (attribute, hidden)
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Utils.Html.Events exposing (onClickMe)


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
            , onClickMe (callback selector)
            ]
            [ value ]


customSelect :
    ( msg, msg )
    -> msg
    -> (comparable -> msg)
    -> comparable
    -> Dict comparable (Html msg)
    -> Bool
    -> Html msg
customSelect ( mouseEnter, mouseLeave ) menuAction callback activeKey itens open =
    let
        options =
            itens
                |> Dict.toList
                |> (List.map <| option callback activeKey)

        active =
            itens
                |> Dict.get activeKey
                |> Maybe.withDefault (text "None")

        openAttr =
            attribute "data-open" <|
                if open then
                    "open"
                else
                    "0"
    in
        node "customSelect"
            [ onClickMe menuAction
            , onMouseEnter mouseEnter
            , onMouseLeave mouseLeave
            , openAttr
            ]
            [ active
            , node "selector" [] options
            ]
