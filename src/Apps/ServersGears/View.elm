module Apps.ServersGears.View exposing (view)

import Html exposing (..)
import Html.Lazy exposing (lazy2)
import Html.CssHelpers
import Game.Data as Game
import Game.Models as GameModels
import Game.Account.Models as Account
import Game.Inventory.Models as Inventory
import Game.Servers.Models as Servers
import Game.Servers.Hardware.Models as Hardware
import Game.Meta.Types.Components as Components exposing (Components)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Apps.ServersGears.Messages exposing (..)
import Apps.ServersGears.Models exposing (..)
import Apps.ServersGears.Resources exposing (Classes(..), prefix)
import Apps.ServersGears.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data model =
    div [] []



--    let
--        motherboard =
--            data
--                |> Game.getActiveServer
--                |> Servers.getHardware
--                |> Hardware.getMotherboard
--    in
--        case motherboard of
--            Just motherboard ->
--                viewGateway data motherboard model
--            Nothing ->
--                viewEndpoint data model
--viewGateway : Game.Data -> Motherboard -> Model -> Html Msg
--viewGateway data motherboard model =
--    let
--        inventory =
--            data
--                |> Game.getGame
--                |> GameModels.getAccount
--                |> Account.getInventory
--    in
--        div [ menuForDummy ]
--            [ menuView model
--            , lazy2 (viewInventory game) inventory model
--            ]
--viewEndpoint : Game.Data -> Model -> Html Msg
--viewEndpoint data model =
--    div [ menuForDummy ]
--        [ menuView model ]
----viewInventory : Game.Data -> Inventory -> Model -> Html Msg
----viewInventory data inventory model =
----    let
----    in
--viewItem : Inventory.Entry -> Inventory.Models -> Html Msg
--viewItem entry inventory =
--    case entry of
--        Inventory.Component id ->
--            case Inventory.getComponent id inventory of
--                Just component ->
--                    div [ disabled <| not Component.isActive ]
--                        [ p [] [ text <| Component.getName component ]
--                        , p [] [ text <| Component.getDescription component ]
--                        ]
--                Nothing ->
--                    text ""
--        Inventory.Connection id ->
--            case Inventory.getConnection id inventory of
--                Just connection ->
--                    div [ disabled <| not Connection.isActive ]
--                        [ p [] [ text <| Connection.getService component ]
--                        , p [] [ text <| Connection.getDescription component ]
--                        ]
--                Nothing ->
--                    text ""
----isDisabled : Inventory.Entry -> Model -> Attribute Msg
----isDisabled entry model =
