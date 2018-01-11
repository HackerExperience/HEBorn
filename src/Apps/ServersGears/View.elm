module Apps.ServersGears.View exposing (view)

import Dict
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (disabled)
import Html.Lazy exposing (lazy, lazy2)
import Html.CssHelpers
import Utils.Html.Events exposing (onClickMe)
import Game.Data as Game
import Game.Models as GameModels
import Game.Inventory.Models as Inventory
import Game.Inventory.Shared as Inventory
import Game.Servers.Models as Servers
import Game.Meta.Types.Components as Components exposing (Components)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Components.Type exposing (Type(..))
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
                    [ lazy2 toolbar motherboard model
                    , div [ class [ MoboSplit ] ]
                        [ lazy (viewMotherboard inventory motherboard) model
                        , lazy2 viewInventory (filterMobo inventory) model
                        ]
                    ]

            Nothing ->
                div [ class [ WindowPick ] ]
                    [ lazy2 viewPickMobo inventory model
                    ]


toolbar : Motherboard -> Model -> Html Msg
toolbar { slots } { selection, anyChange } =
    let
        unlink =
            case selection of
                Just (SelectingSlot slotId) ->
                    case (Maybe.andThen (.component) <| Dict.get slotId slots) of
                        Just _ ->
                            div [ onClick <| Unlink ]
                                [ text "Unlink" ]

                        Nothing ->
                            text ""

                _ ->
                    text ""

        deselect =
            case selection of
                Just _ ->
                    div [ onClick <| Select Nothing ]
                        [ text "Deselect" ]

                Nothing ->
                    text ""

        save =
            if anyChange then
                div [ onClick <| Save ]
                    [ text "Save" ]
            else
                text ""
    in
        div [ class [ Toolbar ] ]
            [ unlink, deselect, save ]


viewMotherboard : Inventory.Model -> Motherboard -> Model -> Html Msg
viewMotherboard inventory motherboard model =
    let
        slots =
            Motherboard.getSlots motherboard
    in
        div [ class [ PanelMobo ] ]
            [ selectedComponent inventory motherboard model
            , div
                [ class [ MoboContainer ]
                ]
                [ guessMobo
                    (SelectingSlot >> Just >> Select)
                    model.highlight
                    motherboard
                ]
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
                |> (++) "Inventory: "
                |> text
                |> List.singleton
                |> div []

        Just (SelectingEntry (Inventory.NetConnection ( _, ip ))) ->
            div [] [ text <| "Inventory:" ++ ip ]

        Nothing ->
            div [] [ text "Nothing selected." ]


viewInventory : Inventory.Model -> Model -> Html Msg
viewInventory inventory model =
    inventory
        |> Inventory.group (isAvailable inventory model)
        |> Dict.toList
        |> List.map (uncurry (viewGroup inventory model))
        -- TODO: Should use UI Vertical List
        |> div [ class [ PanelInvt ] ]


filterMobo : Inventory.Model -> Inventory.Model
filterMobo inventory =
    inventory.components
        |> Dict.filter (\_ compo -> (Components.getType compo) /= MOB)
        |> (\c -> { inventory | components = c })


viewPickMobo : Inventory.Model -> Model -> Html Msg
viewPickMobo inventory model =
    inventory.components
        |> Dict.filter (\_ compo -> (Components.getType compo) == MOB)
        |> (\c -> { inventory | components = c, ncs = Dict.empty })
        |> flip viewInventory model


viewGroup : Inventory.Model -> Model -> String -> Inventory.Group -> Html Msg
viewGroup inventory model name ( available, _ ) =
    div [ class [ Group ] ]
        [ div [ class [ GroupName ] ] [ text name ]
        , div [ class [ GroupAvail ] ] <| List.map (viewEntry inventory model) available
        ]


viewEntry : Inventory.Model -> Model -> Inventory.Entry -> Html Msg
viewEntry inventory model entry =
    viewEntryEnabled (SelectingEntry entry) entry inventory model


viewEntryEnabled :
    Selection
    -> Inventory.Entry
    -> Inventory.Model
    -> Model
    -> Html Msg
viewEntryEnabled selection entry inventory model =
    let
        isHighlighted =
            case entry of
                Inventory.Component id ->
                    inventory.components
                        |> Dict.get id
                        |> Maybe.map (Components.getType)
                        |> (==) model.highlight

                Inventory.NetConnection nc ->
                    model.highlight == Just NIC

        highlight =
            if isHighlighted then
                class [ Highlight ]
            else
                class []

        select =
            onClick <| Select <| Just selection
    in
        inventory
            |> viewEntryContents entry
            |> div [ select, highlight ]


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
