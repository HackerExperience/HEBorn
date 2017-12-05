module Apps.ServersGears.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Game.Models as GameModels
import Game.Servers.Models as Servers
import Game.Servers.Hardware.Models as Hardware
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Apps.ServersGears.Menu.Messages as Menu
import Apps.ServersGears.Menu.Update as Menu
import Apps.ServersGears.Menu.Actions as Menu
import Apps.ServersGears.Messages exposing (..)
import Apps.ServersGears.Models exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update data msg model =
    let
        motherboard =
            data
                |> Game.getActiveServer
                |> Servers.getHardware
                |> Hardware.getMotherboard
    in
        case motherboard of
            Just motherboard ->
                updateGateway data motherboard msg model

            Nothing ->
                updateEndpoint data msg model


updateGateway :
    Game.Data
    -> Motherboard
    -> Msg
    -> Model
    -> UpdateResponse
updateGateway data motherboard msg model =
    updateGeneric data msg model


updateEndpoint :
    Game.Data
    -> Msg
    -> Model
    -> UpdateResponse
updateEndpoint data msg model =
    updateGeneric data msg model


updateGeneric : Game.Data -> Msg -> Model -> UpdateResponse
updateGeneric data msg model =
    case msg of
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        Select selection ->
            onSelectMsg data selection model


onMenuMsg : Game.Data -> Menu.Msg -> Model -> UpdateResponse
onMenuMsg data msg model =
    let
        ( menu_, cmd, coreMsg ) =
            Menu.update data msg model.menu

        cmd_ =
            Cmd.map MenuMsg cmd

        model_ =
            { model | menu = menu_ }
    in
        ( model_, cmd_, coreMsg )


onSelectMsg : Game.Data -> Maybe Selection -> Model -> UpdateResponse
onSelectMsg data selection model =
    let
        inventory =
            data
                |> Game.getGame
                |> GameModels.getInventory
    in
        Update.fromModel <| doSelect selection inventory model
