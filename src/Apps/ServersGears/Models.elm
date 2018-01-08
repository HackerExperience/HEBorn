module Apps.ServersGears.Models exposing (..)

import Dict exposing (Dict)
import Utils.Maybe as Maybe
import Apps.ServersGears.Menu.Models as Menu
import Game.Data as Game
import Game.Inventory.Models as Inventory
import Game.Inventory.Shared as Inventory
import Game.Meta.Types.Components as Components
import Game.Meta.Types.Components.Type exposing (Type(..))
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Servers.Models as Servers
import Game.Servers.Hardware.Models as Hardware


type alias Model =
    { menu : Menu.Model
    , overrides : Overrides
    , selection : Maybe Selection
    , motherboard : Maybe Motherboard
    , anyChange : Bool
    }


type alias Overrides =
    Dict String ( Bool, Inventory.Entry )


type Selection
    = SelectingSlot Motherboard.SlotId
    | SelectingEntry Inventory.Entry


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

        getSlotComponent slotId { component } acu =
            case component of
                Nothing ->
                    acu

                Just id ->
                    ( toString (Inventory.Component id)
                    , ( False, Inventory.Component id )
                    )
                        :: acu

        overrides =
            case motherboard of
                Just motherboard ->
                    Dict.foldl getSlotComponent [] motherboard.slots
                        |> Dict.fromList

                Nothing ->
                    Dict.empty
    in
        { menu =
            Menu.initialMenu
        , overrides =
            overrides
        , selection =
            Nothing
        , motherboard =
            motherboard
        , anyChange =
            False
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
    { model | selection = selection }


removeSelection : Model -> Model
removeSelection =
    setSelection Nothing


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
                    { model | overrides = remove (), anyChange = True }
                else
                    { model | overrides = insert (), anyChange = True }

            Just False ->
                if available then
                    { model | overrides = insert (), anyChange = True }
                else
                    { model | overrides = remove (), anyChange = True }

            Nothing ->
                model


swapSlots :
    Motherboard.SlotId
    -> Motherboard.SlotId
    -> Inventory.Model
    -> Motherboard
    -> Model
    -> Model
swapSlots slotIdA slotIdB inventory motherboard model =
    let
        a =
            Dict.get slotIdA motherboard.slots

        typeA =
            Maybe.map (.type_) a

        compA =
            Maybe.andThen (.component) a

        b =
            Dict.get slotIdB motherboard.slots

        typeB =
            Maybe.map (.type_) b

        compB =
            Maybe.andThen (.component) b
    in
        if typeA == typeB then
            case Maybe.uncurry compA compB of
                Just ( idA, idB ) ->
                    model
                        |> linkSlot slotIdA
                            (Inventory.Component idB)
                            inventory
                            motherboard
                        |> linkSlot slotIdB
                            (Inventory.Component idA)
                            inventory
                            motherboard

                Nothing ->
                    setSelection (Just <| SelectingSlot slotIdB) model
        else
            setSelection (Just <| SelectingSlot slotIdB) model


linkSlot :
    Motherboard.SlotId
    -> Inventory.Entry
    -> Inventory.Model
    -> Motherboard
    -> Model
    -> Model
linkSlot slotId entry inventory motherboard model =
    let
        slot =
            Dict.get slotId motherboard.slots

        typeSlot =
            Maybe.map (.type_) slot

        ( motherboard_, areSameType ) =
            case entry of
                Inventory.Component id ->
                    let
                        areSameType =
                            inventory.components
                                |> Dict.get id
                                |> Maybe.map (Components.getType)
                                |> (==) typeSlot

                        mobo_ =
                            Motherboard.linkComponent slotId id motherboard
                    in
                        ( mobo_, areSameType )

                Inventory.NetConnection nc ->
                    let
                        isValidSlot { type_, component } =
                            case component of
                                Just _ ->
                                    type_ == NIC

                                Nothing ->
                                    False

                        mobo_ =
                            Motherboard.linkNC slotId nc motherboard

                        areSameType =
                            slot
                                |> Maybe.map isValidSlot
                                |> Maybe.withDefault False
                    in
                        ( mobo_, areSameType )
    in
        if areSameType then
            model
                |> setMotherboard motherboard_
                |> setAvailability entry False inventory
                |> removeSelection
        else
            setSelection (Just <| SelectingSlot slotId) model


unlinkSlot : Motherboard.SlotId -> Inventory.Model -> Model -> Model
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
