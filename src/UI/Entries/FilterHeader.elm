module UI.Entries.FilterHeader exposing (filterHeader)

import Html exposing (Html, Attribute, text, node, input)
import Html.Attributes exposing (attribute, placeholder, value)
import Html.Events exposing (onClick, onInput)


type alias Flag msg =
    ( Attribute msg, msg, Bool )


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
        attribute "enabled" value


flagFilter : Flag msg -> Html msg
flagFilter ( iconClasses, onClickMsg, enabled ) =
    node "flagFilterToggle"
        [ iconClasses
        , enabledClass enabled
        , onClick onClickMsg
        ]
        []


flagsFilter : List (Flag msg) -> Html msg
flagsFilter flags =
    let
        entries =
            flags
                |> List.map flagFilter
                |> List.intersperse (text " ")
    in
        node "flagsFilterPanel" [] entries


orderOptions : List (Option msg) -> Html msg
orderOptions options =
    -- TODO
    node "orderBtn" [] []


textFilter : String -> String -> (String -> msg) -> Html msg
textFilter value_ placeholder_ updateMsg =
    node "filterText"
        []
        [ input
            [ placeholder placeholder_
            , value value_
            , onInput updateMsg
            ]
            []
        ]


filterHeader : List (Flag msg) -> List (Option msg) -> String -> String -> (String -> msg) -> Html msg
filterHeader flags options filterValue filterPlaceholder filterUpdateMsg =
    node "filterHeader"
        []
        [ flagsFilter flags
        , node "hSpacer" [] []
        , orderOptions options
        , textFilter filterValue filterPlaceholder filterUpdateMsg
        ]
