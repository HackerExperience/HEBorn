module UI.Widgets.CustomSelect exposing (customSelect, bounceSelect)

import Html exposing (Html, Attribute, node, text, div)
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Utils.Html.Attributes exposing (boolAttr)
import Utils.Html.Events exposing (onClickMe)


customSelect :
    List (Attribute msg)
    -> ( msg, msg )
    -> (a -> msg)
    -> msg
    -> (Bool -> a -> Maybe (Html msg))
    -> Bool
    -> a
    -> List a
    -> Html msg
customSelect attrs ( mouseEnter, mouseLeave ) msg open render opened active list =
    let
        mapper item =
            customOption msg render (item == active) item

        options =
            List.filterMap mapper list

        customNode =
            node selectorNode <|
                attrs
                    ++ [ onMouseEnter mouseEnter
                       , onMouseLeave mouseLeave
                       , onClickMe open
                       , boolAttr openAttrTag opened
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
                    [ boolAttr selectedAttrTag active
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


selectedAttrTag : String
selectedAttrTag =
    "selected"


openAttrTag : String
openAttrTag =
    "open"


bounceSelect :
    (a -> Html msg)
    -> Attribute msg
    -> List (Attribute msg)
    -> ( msg, msg )
    -> (a -> msg)
    -> msg
    -> (Bool -> a -> Maybe (Html msg))
    -> Bool
    -> a
    -> List a
    -> Html msg
bounceSelect tooltip option attrs ( mouseEnter, mouseLeave ) msg open render opened active list =
    let
        mapper item =
            bounceOption tooltip option msg render (item == active) item

        options =
            List.filterMap mapper list

        customAttr =
            attrs
                ++ [ onMouseEnter mouseEnter
                   , onMouseLeave mouseLeave
                   , onClickMe open
                   , boolAttr "open" opened
                   ]

        customNode =
            node "customSelect" (customAttr)

        showTooltip =
            if opened then
                text ""
            else
                tooltip active
    in
        case render True active of
            Just activeNode ->
                div attrs
                    [ customNode [ activeNode, node "selector" [] options ]
                    , showTooltip
                    ]

            Nothing ->
                div attrs
                    [ customNode
                        [ node "selector" [] options
                        ]
                    ]


bounceOption :
    (a -> Html msg)
    -> Attribute msg
    -> (a -> msg)
    -> (Bool -> a -> Maybe (Html msg))
    -> Bool
    -> a
    -> Maybe (Html msg)
bounceOption tooltip option onClick render active item =
    case render active item of
        Just html ->
            Just <|
                div [ option ]
                    [ node "customOption"
                        [ boolAttr "selected" active
                        , onClickMe (onClick item)
                        ]
                        [ html
                        ]
                    , tooltip item
                    ]

        Nothing ->
            Nothing
