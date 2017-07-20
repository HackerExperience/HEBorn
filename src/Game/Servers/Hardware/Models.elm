module Game.Servers.Hardware.Models
    exposing
        ( Model
        , Slots
        , Slot
        , Component
        , initialModel
        , getSlot
        , setSlot
        , getComponent
        , setComponent
        , unsetComponent
        )

import Dict exposing (Dict)
import Game.Account.Inventory.Models as Inventory


type alias Model =
    { id : Inventory.ComponentID
    , spec : Inventory.MOBOSpec
    , slots : Slots
    }


type alias Slots =
    Dict Inventory.SlotID Slot


type alias Slot =
    { internalID : Inventory.InternalSlotID
    , type_ : Inventory.ComponentType
    , component : Maybe Component
    }


type alias Component =
    { id : Inventory.ComponentID
    , spec : Inventory.Component
    }


initialModel : Inventory.ComponentID -> Inventory.MOBOSpec -> Model
initialModel id spec =
    let
        motherboard =
            { id = id
            , spec = spec
            }

        reducer ( id, slot ) slots =
            let
                emptySlot =
                    { internalID = slot.internalID
                    , type_ = slot.type_
                    , component = Nothing
                    }
            in
                Dict.insert id emptySlot slots

        slots =
            List.foldl reducer Dict.empty (Dict.toList spec.slots)

        model =
            { id = id
            , spec = spec
            , slots = slots
            }
    in
        model


getSlot : Inventory.SlotID -> Model -> Maybe Slot
getSlot id { slots } =
    Dict.get id slots


setSlot : Inventory.SlotID -> Slot -> Model -> Model
setSlot id slot ({ slots } as model) =
    let
        slots_ =
            Dict.insert id slot slots

        model_ =
            { model | slots = slots_ }
    in
        model_


getComponent : Slot -> Maybe Component
getComponent =
    .component


setComponent : Component -> Slot -> Slot
setComponent component slot =
    { slot | component = Just component }


unsetComponent : Slot -> Slot
unsetComponent slot =
    { slot | component = Nothing }
