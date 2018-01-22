module Apps.ServersGears.Models exposing (..)

import Dict exposing (Dict)
import Utils.Maybe as Maybe
import Game.Data as Game
import Game.Inventory.Models as Inventory
import Game.Inventory.Shared as Inventory
import Game.Meta.Types.Components as Components
import Game.Meta.Types.Components.Type exposing (Type(..))
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Network.Connections as Connections
import Game.Servers.Models as Servers
import Game.Servers.Hardware.Models as Hardware


type alias Model =
    { overrides : Overrides
    , selection : Maybe Selection
    , motherboard : Maybe Motherboard
    , highlight : Maybe Type
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


initialModel : Maybe Motherboard -> Model
initialModel mobo =
    let
        motherboard =
            mobo
    in
        { overrides =
            findOverrides motherboard
        , selection =
            Nothing
        , motherboard =
            motherboard
        , highlight =
            Nothing
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


setSelection : Maybe Selection -> Maybe Type -> Model -> Model
setSelection selection highlight model =
    { model
        | selection = selection
        , highlight = highlight
    }


removeSelection : Model -> Model
removeSelection =
    setSelection Nothing Nothing


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
            Motherboard.getSlot slotIdA motherboard

        typeA =
            Maybe.map Motherboard.getSlotType a

        compA =
            Maybe.andThen Motherboard.getSlotComponent a

        b =
            Motherboard.getSlot slotIdB motherboard

        typeB =
            Maybe.map Motherboard.getSlotType b

        compB =
            Maybe.andThen Motherboard.getSlotComponent b
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
                    setSelection
                        (Just <| SelectingSlot slotIdB)
                        typeB
                        model
        else
            setSelection
                (Just <| SelectingSlot slotIdB)
                typeB
                model


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
            Motherboard.getSlot slotId motherboard

        typeSlot =
            Maybe.map Motherboard.getSlotType slot

        ( motherboard_, areSameType, isSlotFree ) =
            case entry of
                Inventory.Component compId ->
                    compareComponentLink typeSlot
                        slotId
                        compId
                        inventory
                        motherboard

                Inventory.NetConnection nc ->
                    compareNetConn slotId
                        slot
                        nc
                        motherboard

        maybeUnlink model =
            if isSlotFree then
                model
            else
                unlinkSlot slotId inventory model
    in
        if areSameType then
            model
                |> maybeUnlink
                |> setMotherboard motherboard_
                |> setAvailability entry False inventory
                |> removeSelection
        else
            setSelection
                (Just <| SelectingSlot slotId)
                typeSlot
                model


compareComponentLink :
    Maybe Type
    -> Motherboard.SlotId
    -> Components.Id
    -> Inventory.Model
    -> Motherboard
    -> ( Motherboard, Bool, Bool )
compareComponentLink typeSlot slotId id inventory motherboard =
    let
        areSameType =
            inventory.components
                |> Dict.get id
                |> Maybe.map (Components.getType)
                |> (==) typeSlot

        isSlotFree =
            motherboard
                |> Motherboard.getSlots
                |> Dict.get slotId
                |> Maybe.andThen .component
                |> Maybe.isNothing

        mobo_ =
            Motherboard.linkComponent slotId id motherboard
    in
        ( mobo_, areSameType, isSlotFree )


compareNetConn :
    Motherboard.SlotId
    -> Maybe Motherboard.Slot
    -> Connections.Id
    -> Motherboard
    -> ( Motherboard, Bool, Bool )
compareNetConn slotId slot nc motherboard =
    case slot of
        Just { type_, component } ->
            case component of
                Just compoId ->
                    ( Motherboard.linkNC compoId nc motherboard
                    , type_ == NIC
                    , Maybe.isNothing <| Motherboard.getNC compoId motherboard
                    )

                Nothing ->
                    ( motherboard
                    , False
                    , False
                    )

        Nothing ->
            ( motherboard
            , False
            , False
            )


unlinkSlot : Motherboard.SlotId -> Inventory.Model -> Model -> Model
unlinkSlot slotId inventory model =
    let
        maybeMotherboard =
            getMotherboard model

        maybeCompId =
            Maybe.andThen (Motherboard.getComponent slotId) maybeMotherboard

        maybeNC compId =
            Maybe.andThen (Motherboard.getNC compId) maybeMotherboard

        setNCAvailability compId mobo =
            case maybeNC compId of
                Just nip ->
                    setAvailability (Inventory.NetConnection nip) True inventory mobo

                Nothing ->
                    mobo
    in
        case Maybe.uncurry maybeMotherboard maybeCompId of
            Just ( motherboard, id ) ->
                motherboard
                    |> Motherboard.unlinkNC id
                    |> Motherboard.unlinkComponent slotId
                    |> flip setMotherboard model
                    |> setAvailability (Inventory.Component id) True inventory
                    |> setNCAvailability id
                    |> removeSelection

            Nothing ->
                removeSelection model


highlightSlot :
    Motherboard.SlotId
    -> Motherboard
    -> Maybe Selection
    -> Model
    -> Model
highlightSlot slotId mobo selection_ =
    mobo
        |> Motherboard.getSlot slotId
        |> Maybe.map Motherboard.getSlotType
        |> setSelection selection_


highlightComponent :
    Inventory.Entry
    -> Inventory.Model
    -> Maybe Selection
    -> Model
    -> Model
highlightComponent entry { components } selection_ =
    case entry of
        Inventory.Component id ->
            components
                |> Dict.get id
                |> Maybe.map Components.getType
                |> setSelection selection_

        Inventory.NetConnection nc ->
            setSelection selection_ (Just NIC)


findOverrides : Maybe Motherboard -> Overrides
findOverrides motherboard =
    let
        getSlotEntry slotId { component } acu =
            case component of
                Nothing ->
                    acu

                Just id ->
                    ( toString (Inventory.Component id)
                    , ( False, Inventory.Component id )
                    )
                        :: acu

        getNCEntry compoId conn acu =
            ( toString (Inventory.NetConnection conn)
            , ( False, Inventory.NetConnection conn )
            )
                :: acu

        slotsOverrides mobo acu =
            Motherboard.getSlots mobo
                |> Dict.foldl getSlotEntry acu

        ncsOverrides mobo acu =
            Motherboard.getNCs mobo
                |> Dict.foldl getNCEntry acu
    in
        case motherboard of
            Just mobo ->
                []
                    |> slotsOverrides mobo
                    |> ncsOverrides mobo
                    |> Dict.fromList

            Nothing ->
                Dict.empty
