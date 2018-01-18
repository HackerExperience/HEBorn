module UI.Widgets.Modal
    exposing
        ( modal
        , modalPickStorage
        , modalOkCancel
        , modalNode
        , overlayNode
        )

import Dict exposing (Dict)
import Html exposing (Html, Attribute, node, div, button, text, h3, span)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Game.Servers.Models exposing (Storages)
import OS.SessionManager.WindowManager.Resources exposing (..)


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
