module UI.Entries.FilterHeader exposing (filterHeader)

import Html exposing (Html, Attribute, text, node, input)
import Html.Attributes exposing (attribute, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers exposing (withNamespace)


{ id, class, classList } =
    withNamespace "ui"


type alias Flag class msg =
    ( class, msg, Bool )


type alias Option msg =
    ( String, msg, Bool )


enabledClass : Bool -> Html.Attribute msg
enabledClass enabled =
    let
        value =
            if enabled then
                "1"
            else
                "0"
    in
        attribute "data-enabled" value


renderFlagFilter : Flag class msg -> Html msg
renderFlagFilter ( iconClass, onClickMsg, enabled ) =
    node "flagFilterToggle"
        [ class
            [ iconClass ]
        , enabledClass enabled
        , onClick onClickMsg
        ]
        []


renderFlagsFilter : List (Flag class msg) -> Html msg
renderFlagsFilter flags =
    let
        entries =
            flags
                |> List.map renderFlagFilter
                |> List.intersperse (text " ")
    in
        node "flagsFilterPanel" [] entries


renderOrderOptions : List (Option msg) -> Html msg
renderOrderOptions options =
    -- TODO
    node "orderBtn" [] []


renderTextFilter : String -> String -> (String -> msg) -> Html msg
renderTextFilter value_ placeholder_ updateMsg =
    node "filterText"
        []
        [ input
            [ placeholder placeholder_
            , value value_
            , onInput updateMsg
            ]
            []
        ]


filterHeader : List (Flag class msg) -> List (Option msg) -> String -> String -> (String -> msg) -> Html msg
filterHeader flags options filterValue filterPlaceholder filterUpdateMsg =
    node "filterHeader"
        []
        [ renderFlagsFilter flags
        , node "hSpacer" [] []
        , renderOrderOptions options
        , renderTextFilter filterValue filterPlaceholder filterUpdateMsg
        ]
