module UI.Widgets.Modal
    exposing
        ( modal
        , modalPickStorage
        , modalOk
        , modalOkCancel
        , modalNode
        , modalFrame
        , overlayNode
        , select
        , buttons
        , okCancelButtons
        , selectedAttrTag
        )

import Dict exposing (Dict)
import Html exposing (Html, Attribute, node, div, button, text, h3, span)
import Html.Events exposing (onClick)
import UI.Widgets.CustomSelect exposing (customSelect)
import Game.Servers.Models exposing (Storages)


-- example usage: `modal "Are you sure?" []`


modalPickStorage : Storages -> (Maybe String -> msg) -> Html msg
modalPickStorage storages pickResponse =
    let
        storageReducer key value acu =
            ( pickResponse <| Just key, value.name ) :: acu

        storagesBtns =
            Dict.foldr storageReducer [] storages

        btns =
            storagesBtns
                |> (::) ( pickResponse Nothing, "Cancel" )
                |> List.reverse

        cancel =
            (Just <| pickResponse Nothing)
    in
        modal (Just "Pick a storage")
            "Select where you want to save oswaldo:"
            btns
            cancel


modalOk : Maybe String -> String -> msg -> Html msg
modalOk title content ok =
    modal title content [ ( ok, "Ok" ) ] Nothing


modalOkCancel : Maybe String -> String -> msg -> msg -> Html msg
modalOkCancel title content ok cancel =
    modal title content [ ( ok, "Ok" ), ( cancel, "Cancel" ) ] Nothing


modal : Maybe String -> String -> List ( msg, String ) -> Maybe msg -> Html msg
modal title content buttons fallback =
    let
        buttons_ =
            let
                reducer ( action, content ) buttons =
                    button
                        [ onClick action ]
                        [ text content ]
                        :: buttons
            in
                node btnsNode [] <|
                    List.foldr reducer [] buttons

        msg =
            [ span [] [ text content ] ]

        main =
            case title of
                Just title ->
                    h3 [] [ text title ] :: msg

                Nothing ->
                    msg

        content_ =
            node contentNode
                []
                [ node msgNode [] main
                , buttons_
                ]
                |> List.singleton
                |> node containerNode []

        root =
            node modalNode [] [ overlay fallback, content_ ]
    in
        root



--ModalMac


modalFrame :
    Maybe String
    -> List (Html msg)
    -> List (Html msg)
    -> Html msg
modalFrame title body buttons =
    let
        main =
            case title of
                Just title ->
                    h3 [] [ text title ] :: body

                Nothing ->
                    body

        content_ =
            node contentNode
                []
                [ node msgNode [] main
                , node btnsNode [] buttons
                ]
                |> List.singleton
                |> node containerNode []

        root =
            node modalNode [] [ overlay Nothing, content_ ]
    in
        root


buttons :
    List ( msg, String )
    -> List (Html msg)
buttons buttons =
    let
        reducer ( action, content ) buttons =
            button
                [ onClick action ]
                [ text content ]
                :: buttons
    in
        List.foldr reducer [] buttons


select :
    List String
    -> Maybe String
    -> (Maybe String -> msg)
    -> Html msg
select list selected selectMsg =
    let
        reducer member acu =
            Html.option [ onClick <| selectMsg (Just member) ] [ text member ]
                |> flip (::) acu

        select_ =
            List.foldr reducer [] list
                |> Html.select []
    in
        select_


okCancelButtons : msg -> msg -> List (Html msg)
okCancelButtons okMsg cancelMsg =
    buttons [ ( okMsg, "Ok" ), ( cancelMsg, "Cancel" ) ]


overlay : Maybe msg -> Html msg
overlay fallback =
    let
        attr =
            fallback
                |> Maybe.map (onClick >> List.singleton)
                |> Maybe.withDefault []
    in
        node overlayNode attr []


modalNode : String
modalNode =
    "modal"


btnsNode : String
btnsNode =
    "btns"


contentNode : String
contentNode =
    "content"


containerNode : String
containerNode =
    "container"


msgNode : String
msgNode =
    "msg"


overlayNode : String
overlayNode =
    "overlay"


selectedAttrTag : String
selectedAttrTag =
    "selected"
