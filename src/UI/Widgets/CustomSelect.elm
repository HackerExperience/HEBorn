module UI.Widgets.CustomSelect exposing (Msg(..), customSelect)

import Html exposing (Html, Attribute, node, text)
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Utils.Html.Attributes exposing (selectedAttr, openAttr)
import Utils.Html.Events exposing (onClickMe)


type Msg
    = MouseEnter
    | MouseLeave


customSelect :
    List (Attribute msg)
    -> (Msg -> msg)
    -> (a -> msg)
    -> msg
    -> (Bool -> a -> Maybe (Html msg))
    -> Bool
    -> a
    -> List a
    -> Html msg
customSelect attrs wrap msg open render opened active list =
    let
        mapper item =
            customOption msg render (item == active) item

        options =
            List.filterMap mapper list

        customNode =
            node selectorNode <|
                (++) attrs
                    [ onMouseEnter <| wrap MouseEnter
                    , onMouseLeave <| wrap MouseLeave
                    , onClickMe open
                    , openAttr opened
                    ]
    in
        case render True active of
            Just activeNode ->
                customNode [ activeNode, selector options ]

            Nothing ->
                customNode [ selector options ]


customOption :
    (a -> msg)
    -> (Bool -> a -> Maybe (Html msg))
    -> Bool
    -> a
    -> Maybe (Html msg)
customOption onClick render active item =
    case render active item of
        Just html ->
            Just <|
                node optionNode
                    [ selectedAttr active
                    , onClickMe (onClick item)
                    ]
                    [ html ]

        Nothing ->
            Nothing


selector : List (Html msg) -> Html msg
selector =
    node "selector" []


optionNode : String
optionNode =
    "customOption"


selectorNode : String
selectorNode =
    "customSelect"
