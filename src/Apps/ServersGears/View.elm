module Apps.ServersGears.View exposing (view)

import Dict
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (disabled)
import Html.Lazy exposing (lazy, lazy2)
import Html.CssHelpers
import Game.Data as Game
import Game.Models as GameModels
import Game.Inventory.Models as Inventory
import Game.Inventory.Shared as Inventory
import Game.Servers.Models as Servers
import Game.Meta.Types.Components as Components exposing (Components)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Network.Connections as NetConnections exposing (Connections)
import Apps.ServersGears.Messages exposing (..)
import Apps.ServersGears.Models exposing (..)
import Apps.ServersGears.Resources exposing (Classes(..), prefix)
import UI.Widgets.Motherboard exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data model =
    let
        isGateway =
            data
                |> Game.getActiveServer
                |> Servers.isGateway
    in
        if isGateway then
            editablePanel data model
        else
            readonlyPanel data model


readonlyPanel : Game.Data -> Model -> Html Msg
readonlyPanel data model =
    -- TODO: when totals are available
    div [ class [ WindowRO ] ]
        []


editablePanel : Game.Data -> Model -> Html Msg
editablePanel data model =
    let
        inventory =
            data
                |> Game.getGame
                |> GameModels.getInventory
    in
        case getMotherboard model of
            Just motherboard ->
                div [ class [ WindowFull ] ]
                    [ toolbar
                    , div [ class [ MoboSplit ] ]
                        [ lazy (viewMotherboard inventory motherboard) model
                        , lazy2 viewInventory inventory model
                        ]
                    ]

            Nothing ->
                div [ class [ WindowPick ] ]
                    [ lazy2 viewInventory inventory model
                    ]


toolbar : Html Msg
toolbar =
    div [ class [ Toolbar ] ]
        [ div [ onClick <| Select (Just SelectingUnlink) ]
            [ text "unlink" ]
        , div [ onClick <| Select Nothing ]
            [ text "deselect" ]
        , div [ onClick <| Save ]
            [ text "save" ]
        ]


viewMotherboard : Inventory.Model -> Motherboard -> Model -> Html Msg
viewMotherboard inventory motherboard model =
    let
        slots =
            Motherboard.getSlots motherboard
    in
        div [ class [ PanelMobo ] ]
            [ selectedComponent inventory motherboard model
            , div [ class [ MoboContainer ] ]
                [ defaultMobo (SelectingSlot >> Just >> Select) motherboard ]
            ]


selectedComponent : Inventory.Model -> Motherboard -> Model -> Html Msg
selectedComponent { components } { slots } { selection } =
    case selection of
        Just (SelectingSlot slotId) ->
            Dict.get slotId slots
                |> Maybe.andThen .component
                |> Maybe.andThen (flip Dict.get components)
                |> Maybe.map (.spec >> .name >> (++) "Linked: ")
                |> Maybe.withDefault "Empty Slot"
                |> text
                |> List.singleton
                |> div []

        Just (SelectingEntry (Inventory.Component id)) ->
            Dict.get id components
                |> Maybe.map (.spec >> .name)
                |> Maybe.withDefault "?"
                |> (++) "Unlinked: "
                |> text
                |> List.singleton
                |> div []

        Just (SelectingEntry (Inventory.NetConnection ( _, ip ))) ->
            div [] [ text <| "Unlinked:" ++ ip ]

        Just SelectingUnlink ->
            div [] [ text "Just clicked unlink." ]

        _ ->
            div [] [ text "Nothing selected." ]


viewInventory : Inventory.Model -> Model -> Html Msg
viewInventory inventory model =
    inventory
        |> Inventory.group (isAvailable inventory model)
        |> Dict.toList
        |> List.map (uncurry (viewGroup inventory model))
        |> div [ class [ PanelInvt ] ]


viewGroup : Inventory.Model -> Model -> String -> Inventory.Group -> Html Msg
viewGroup inventory model name ( available, _ ) =
    div [ class [ Group ] ]
        [ div [ class [ GroupName ] ] [ text name ]
        , div [ class [ GroupAvail ] ] <| List.map (viewEntry inventory model) available
        ]


viewEntry : Inventory.Model -> Model -> Inventory.Entry -> Html Msg
viewEntry inventory model entry =
    -- it's also possible to check the model selection to add effects to
    -- selected entries and slots
    let
        selection =
            SelectingEntry entry
    in
        if isMatching selection inventory model then
            viewEntryEnabled selection entry inventory model
        else
            viewEntryDisabled entry inventory


viewEntryEnabled :
    Selection
    -> Inventory.Entry
    -> Inventory.Model
    -> Model
    -> Html Msg
viewEntryEnabled selection entry inventory model =
    div [ onClick <| Select <| Just selection ] <|
        viewEntryContents entry inventory


viewEntryDisabled : Inventory.Entry -> Inventory.Model -> Html Msg
viewEntryDisabled entry inventory =
    div [ disabled True ] <|
        viewEntryContents entry inventory


viewEntryContents : Inventory.Entry -> Inventory.Model -> List (Html Msg)
viewEntryContents entry inventory =
    case entry of
        Inventory.Component id ->
            case Inventory.getComponent id inventory of
                Just component ->
                    [ div [] [ text <| Components.getName component ]
                    , div [] [ text <| Components.getDescription component ]
                    ]

                Nothing ->
                    []

        Inventory.NetConnection id ->
            case Inventory.getNC id inventory of
                Just nc ->
                    [ div [] [ text <| NetConnections.getName nc ]
                    ]

                Nothing ->
                    []
