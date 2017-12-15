module Apps.ServersGears.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as ServersDispatch
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
    case getMotherboard model of
        Just motherboard ->
            updateGateway data motherboard msg model

        Nothing ->
            updateEndpoint data msg model



-- gateway-only update


updateGateway :
    Game.Data
    -> Motherboard
    -> Msg
    -> Model
    -> UpdateResponse
updateGateway data motherboard msg model =
    case msg of
        Save ->
            onSave data motherboard model

        msg ->
            updateGeneric data msg model


onSave : Game.Data -> Motherboard -> Model -> UpdateResponse
onSave game motherboard model =
    let
        cid =
            Game.getActiveCId game

        dispatch =
            Dispatch.hardware cid <|
                ServersDispatch.MotherboardUpdate motherboard
    in
        ( model, Cmd.none, dispatch )



-- endpoint-only update


updateEndpoint :
    Game.Data
    -> Msg
    -> Model
    -> UpdateResponse
updateEndpoint data msg model =
    updateGeneric data msg model



-- generic update


updateGeneric : Game.Data -> Msg -> Model -> UpdateResponse
updateGeneric data msg model =
    case msg of
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        Select selection ->
            onSelectMsg data selection model

        _ ->
            Update.fromModel model


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
