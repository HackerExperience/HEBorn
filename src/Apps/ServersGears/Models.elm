module Apps.ServersGears.Models exposing (..)

import Dict exposing (Dict)
import Utils.Maybe as Maybe
import Apps.ServersGears.Menu.Models as Menu
import Game.Data as Game
import Game.Inventory.Models as Inventory
import Game.Inventory.Shared as Inventory
import Game.Meta.Types.Components as Components
import Game.Meta.Types.Components.Type as Components
import Game.Meta.Types.Network.Connections as NetConnections
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Components.Motherboard.Diff as Motherboard
import Game.Servers.Models as Servers
import Game.Servers.Hardware.Models as Hardware


type alias Model =
    { menu : Menu.Model
    , overrides : Overrides
    , selection : Maybe Selection
    , motherboard : Maybe Motherboard
    }


type alias Overrides =
    Dict String ( Bool, Inventory.Entry )


type Selection
    = SelectingSlot Motherboard.Id
    | SelectingEntry Inventory.Entry
    | SelectingUnlink


name : String
name =
    "Servers Gears"


title : Model -> String
title model =
    "Servers Gears"


icon : String
icon =
    "srvgr"


initialModel : Game.Data -> Model
initialModel data =
    let
        motherboard =
            data
                |> Game.getActiveServer
                |> Servers.getHardware
                |> Hardware.getMotherboard
    in
        { menu =
            Menu.initialMenu
        , overrides =
            Dict.empty
        , selection =
            Nothing
        , motherboard =
            motherboard
        }


getMotherboard : Model -> Maybe Motherboard
getMotherboard =
    .motherboard


setMotherboard : Motherboard -> Model -> Model
setMotherboard motherboard model =
    { model | motherboard = Just motherboard }


getSelection : Model -> Maybe Selection
getSelection =
    .selection


setSelection : Maybe Selection -> Model -> Model
setSelection selection model =
    case selection of
        Just SelectingUnlink ->
            setSelection Nothing model

        _ ->
            { model | selection = selection }


removeSelection : Model -> Model
removeSelection =
    setSelection Nothing


doSelect : Maybe Selection -> Inventory.Model -> Model -> Model
doSelect selection inventory model =
    case getSelection model of
        Just (SelectingSlot id) ->
            case selection of
                Just (SelectingSlot id_) ->
                    -- swap slots
                    case getMotherboard model of
                        Just motherboard ->
                            -- swap two slots
                            swapSlots id id_ inventory motherboard model

                        Nothing ->
                            -- can't perform slot actions without a mobo
                            model

                Just (SelectingEntry entry) ->
                    -- link the slot to the inventory entry
                    linkSlot id entry inventory model

                Just SelectingUnlink ->
                    -- unlink that slot
                    unlinkSlot id inventory model

                Nothing ->
                    -- remove slot selection
                    removeSelection model

        Just (SelectingEntry entry) ->
            case selection of
                Just (SelectingSlot id) ->
                    -- link the inventory entry to the slot
                    linkSlot id entry inventory model

                Just (SelectingEntry _) ->
                    -- change selection to another inventory entry
                    setSelection selection model

                Just SelectingUnlink ->
                    -- why click on unlink without selecting a slot?
                    model

                Nothing ->
                    -- remove entry selection
                    removeSelection model

        Just SelectingUnlink ->
            -- why click on unlink without selecting anything?
            removeSelection model

        Nothing ->
            -- select
            setSelection selection model


isAvailable : Inventory.Model -> Model -> Inventory.Entry -> Bool
isAvailable inventory model entry =
    let
        key =
            toString entry
    in
        case Dict.get key model.overrides of
            Just ( state, _ ) ->
                state

            Nothing ->
                inventory
                    |> Inventory.isAvailable entry
                    |> Maybe.withDefault False


setAvailability : Inventory.Entry -> Bool -> Inventory.Model -> Model -> Model
setAvailability entry available inventory model =
    let
        key =
            toString entry

        remove () =
            Dict.remove key model.overrides

        insert () =
            Dict.insert key ( available, entry ) model.overrides
    in
        case Inventory.isAvailable entry inventory of
            Just True ->
                if available then
                    { model | overrides = remove () }
                else
                    { model | overrides = insert () }

            Just False ->
                if available then
                    { model | overrides = insert () }
                else
                    { model | overrides = remove () }

            Nothing ->
                model


removeNetConnection : Motherboard.Id -> Inventory.Model -> Model -> Model
removeNetConnection slotId inventory model =
    let
        maybeMotherboard =
            getMotherboard model

        maybeComponentId =
            Maybe.andThen (Motherboard.getComponent slotId) maybeMotherboard

        maybeMoboAndCompId =
            Maybe.uncurry maybeMotherboard maybeComponentId

        maybeNetConnection =
            case maybeMoboAndCompId of
                Just ( motherboard, componentId ) ->
                    motherboard
                        |> Motherboard.getNC componentId
                        |> Maybe.map Inventory.NetConnection

                Nothing ->
                    Nothing
    in
        case Maybe.uncurry maybeMoboAndCompId maybeNetConnection of
            Just ( ( motherboard, compId ), entry ) ->
                motherboard
                    |> Motherboard.unlinkNC compId
                    |> flip setMotherboard model
                    |> setAvailability entry False inventory
                    |> removeSelection

            Nothing ->
                model


isMatching :
    Selection
    -> Inventory.Model
    -> Model
    -> Bool
isMatching selection inventory model =
    case getSelection model of
        Just (SelectingEntry entry) ->
            case selection of
                SelectingEntry _ ->
                    -- allow changing selected entry
                    True

                SelectingSlot id ->
                    -- highlight slots of the same entry type
                    checkWithMotherboard (doesTypesMatch id entry inventory)
                        model

                SelectingUnlink ->
                    -- can't unlink from inventory
                    False

        Just (SelectingSlot id) ->
            case selection of
                SelectingEntry entry ->
                    -- highlight entries of the same slot type
                    checkWithMotherboard (doesTypesMatch id entry inventory)
                        model

                SelectingSlot id_ ->
                    -- allow changing component from slot when they
                    -- match types
                    checkWithMotherboard (doesSlotsSwap id id_)
                        model

                SelectingUnlink ->
                    -- allow unlinking linked slots
                    checkWithMotherboard (isSlotFilled id)
                        model

        Just SelectingUnlink ->
            -- can't click on unlink when no slot is selected
            False

        Nothing ->
            -- allow setting selection to anything
            True



-- internals - isMatching helpers


checkWithMotherboard : (Motherboard -> Bool) -> Model -> Bool
checkWithMotherboard func model =
    model
        |> getMotherboard
        |> Maybe.map func
        |> Maybe.withDefault False


doesTypesMatch :
    Motherboard.Id
    -> Inventory.Entry
    -> Inventory.Model
    -> Motherboard
    -> Bool
doesTypesMatch id entry inventory motherboard =
    case Motherboard.getSlot id motherboard of
        Just slot ->
            case entry of
                Inventory.Component id ->
                    -- component and slot types match
                    let
                        slotType =
                            Motherboard.getSlotType slot

                        isEmpty =
                            Motherboard.slotIsEmpty slot

                        maybeComponentType =
                            inventory
                                |> Inventory.getComponent id
                                |> Maybe.map Components.getType
                    in
                        case maybeComponentType of
                            Just componentType ->
                                isEmpty && (slotType == componentType)

                            Nothing ->
                                False

                Inventory.NetConnection nc ->
                    -- slot is a nic slot and it's empty
                    let
                        slotType =
                            Motherboard.getSlotType slot

                        isEmpty =
                            Motherboard.slotIsEmpty slot
                    in
                        isEmpty && (slotType == Components.NIC)

        Nothing ->
            -- slot isn't found, why bother checking?
            False


doesSlotsSwap : Motherboard.Id -> Motherboard.Id -> Motherboard -> Bool
doesSlotsSwap id1 id2 motherboard =
    let
        maybeSlot1 =
            Motherboard.getSlot id1 motherboard

        maybeSlot2 =
            Motherboard.getSlot id2 motherboard
    in
        case Maybe.uncurry maybeSlot1 maybeSlot2 of
            Just ( slot1, slot2 ) ->
                let
                    slot1T =
                        Motherboard.getSlotType slot1

                    slot2T =
                        Motherboard.getSlotType slot2

                    isEmpty =
                        Motherboard.slotIsEmpty slot2
                in
                    isEmpty && (slot1T == slot2T)

            Nothing ->
                -- slots not found, why bother?
                False


isSlotFilled : Motherboard.Id -> Motherboard -> Bool
isSlotFilled id motherboard =
    motherboard
        |> Motherboard.getSlot id
        |> Maybe.map (Motherboard.slotIsEmpty >> not)
        |> Maybe.withDefault False



-- internals - doSelect helpers


swapSlots :
    Motherboard.Id
    -> Motherboard.Id
    -> Inventory.Model
    -> Motherboard
    -> Model
    -> Model
swapSlots slotIdA slotIdB inventory motherboard model =
    let
        maybeA =
            Motherboard.getComponent slotIdA motherboard

        maybeB =
            Motherboard.getComponent slotIdB motherboard
    in
        case Maybe.uncurry maybeA maybeB of
            Just ( idA, idB ) ->
                model
                    |> linkSlot slotIdA
                        (Inventory.Component idB)
                        inventory
                    |> linkSlot slotIdB
                        (Inventory.Component idA)
                        inventory

            Nothing ->
                removeSelection model


linkSlot :
    Motherboard.Id
    -> Inventory.Entry
    -> Inventory.Model
    -> Model
    -> Model
linkSlot slotId entry inventory model =
    case getMotherboard model of
        Just motherboard ->
            let
                motherboard_ =
                    case entry of
                        Inventory.Component id ->
                            Motherboard.linkComponent slotId id motherboard

                        Inventory.NetConnection nc ->
                            Motherboard.linkNC slotId nc motherboard
            in
                model
                    |> setMotherboard motherboard_
                    |> setAvailability entry False inventory
                    |> removeSelection

        Nothing ->
            removeSelection model


unlinkSlot : Motherboard.Id -> Inventory.Model -> Model -> Model
unlinkSlot slotId inventory model =
    let
        maybeMotherboard =
            getMotherboard model

        maybeCompId =
            Maybe.andThen (Motherboard.getComponent slotId) maybeMotherboard
    in
        case Maybe.uncurry maybeMotherboard maybeCompId of
            Just ( motherboard, id ) ->
                motherboard
                    |> Motherboard.unlinkComponent slotId
                    |> flip setMotherboard model
                    |> setAvailability (Inventory.Component id) True inventory
                    |> removeSelection

            Nothing ->
                removeSelection model
