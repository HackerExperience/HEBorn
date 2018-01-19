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

        model_ =
            { model | anyChange = False }
    in
        ( model_, Cmd.none, dispatch )



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
        Select selection ->
            onSelectMsg data selection model

        Unlink ->
            onUnlinkMsg data model

        _ ->
            Update.fromModel model


onSelectMsg : Game.Data -> Maybe Selection -> Model -> UpdateResponse
onSelectMsg data selection_ model =
    let
        inv =
            data
                |> Game.getGame
                |> GameModels.getInventory
    in
        case ( model.motherboard, model.selection, selection_ ) of
            ( Just mobo, Just (SelectingSlot slotA), Just (SelectingSlot slotB) ) ->
                model
                    |> swapSlots slotA slotB inv mobo
                    |> Update.fromModel

            ( Just mobo, Just (SelectingEntry entry), Just (SelectingSlot slot) ) ->
                model
                    |> linkSlot slot entry inv mobo
                    |> Update.fromModel

            ( Just mobo, Just (SelectingSlot slot), Just (SelectingEntry entry) ) ->
                let
                    fixSelection model_ =
                        if model_.selection == model.selection then
                            highlightComponent entry inv selection_ model_
                        else
                            model_
                in
                    model
                        |> linkSlot slot entry inv mobo
                        |> fixSelection
                        |> Update.fromModel

            ( Just mobo, _, Just (SelectingSlot slotId) ) ->
                model
                    |> highlightSlot slotId mobo selection_
                    |> Update.fromModel

            ( _, _, Just (SelectingEntry entry) ) ->
                model
                    |> highlightComponent entry inv selection_
                    |> Update.fromModel

            _ ->
                model
                    |> setSelection
                        selection_
                        Nothing
                    |> Update.fromModel


onUnlinkMsg : Game.Data -> Model -> UpdateResponse
onUnlinkMsg data model =
    case model.selection of
        Just (SelectingSlot slot) ->
            let
                inv =
                    data
                        |> Game.getGame
                        |> GameModels.getInventory
            in
                model
                    |> unlinkSlot slot inv
                    |> Update.fromModel

        _ ->
            model
                |> removeSelection
                |> Update.fromModel
