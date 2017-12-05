module Apps.ServersGears.View exposing (view)

import Dict
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (disabled)
import Html.Lazy exposing (lazy2)
import Html.CssHelpers
import Game.Data as Game
import Game.Models as GameModels
import Game.Account.Models as Account
import Game.Inventory.Models as Inventory
import Game.Inventory.Shared as Inventory
import Game.Servers.Models as Servers
import Game.Servers.Hardware.Models as Hardware
import Game.Meta.Types.Components as Components exposing (Components)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Network.Connections as NetConnections exposing (Connections)
import Apps.ServersGears.Messages exposing (..)
import Apps.ServersGears.Models exposing (..)
import Apps.ServersGears.Resources exposing (Classes(..), prefix)
import Apps.ServersGears.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data model =
    div [] []


readonlyPanel : Game.Data -> Model -> Html Msg
readonlyPanel data model =
    -- TODO: when totals are available
    div []
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
                div []
                    [ viewMotherboard inventory motherboard model
                    , viewInventory inventory model
                    ]

            Nothing ->
                div []
                    [ viewInventory inventory model
                    ]


viewMotherboard : Inventory.Model -> Motherboard -> Model -> Html Msg
viewMotherboard inventory motherboard model =
    div [] []


viewSlot :
    Inventory.Model
    -> Motherboard
    -> Model
    -> Motherboard.Id
    -> Motherboard.Slot
    -> Html Msg
viewSlot inventory motherboard model id slot =
    let
        selection =
            SelectingSlot id

        maybeId =
            Motherboard.getSlotComponent slot

        maybeNC =
            slot
                |> Motherboard.getSlotComponent
                |> Maybe.andThen (flip Motherboard.getNC motherboard)

        networkText =
            case maybeNC of
                Just nc ->
                    text ("With NC " ++ toString nc)

                Nothing ->
                    text ""

        content0 =
            case maybeId of
                Just id ->
                    viewEntryContents (Inventory.Component id) inventory

                Nothing ->
                    []

        content =
            content0 ++ [ networkText ]
    in
        if isMatching selection inventory model then
            div [ onClick <| Select <| Just selection ]
                content
        else
            div [ disabled True ]
                content


viewInventory : Inventory.Model -> Model -> Html Msg
viewInventory inventory model =
    inventory
        |> Inventory.group (isAvailable inventory model)
        |> Dict.toList
        |> List.map (uncurry (viewGroup inventory model))
        |> div []


viewGroup : Inventory.Model -> Model -> String -> Inventory.Group -> Html Msg
viewGroup inventory model name ( available, unavailable ) =
    div []
        [ p [] [ text name ]
        , div [] <| List.map (viewEntry inventory model) available
        , hr [] []
        , div [] <| List.map (flip viewEntryDisabled inventory) unavailable
        ]


viewEntry : Inventory.Model -> Model -> Inventory.Entry -> Html Msg
viewEntry inventory model entry =
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
                    [ p [] [ text <| Components.getName component ]
                    , p [] [ text <| Components.getDescription component ]
                    ]

                Nothing ->
                    []

        Inventory.NetConnection id ->
            case Inventory.getNC id inventory of
                Just nc ->
                    [ p [] [ text <| NetConnections.getName nc ]
                    ]

                Nothing ->
                    []
