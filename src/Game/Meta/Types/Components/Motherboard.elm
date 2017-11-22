module Game.Meta.Types.Components.Motherboard exposing (..)

import Dict exposing (Dict)
import Game.Meta.Types.Components.Type as Components
import Game.Meta.Types.Components as Components exposing (Components)
import Game.Meta.Types.Network.Connections as Connections exposing (Connections)


type alias Motherboard =
    { id : Maybe Components.Id
    , networks : Networks
    , slots : Slots
    }


type alias Networks =
    Dict Components.Id Connections.Id


type alias Slots =
    Dict Id Slot


type alias Id =
    String


type alias Slot =
    { type_ : Components.Type
    , component : Maybe Components.Id
    }


empty : Motherboard
empty =
    { id = Nothing
    , networks = Dict.empty
    , slots = Dict.empty
    }


getComponent : Id -> Motherboard -> Maybe Components.Id
getComponent id motherboard =
    motherboard.slots
        |> Dict.get id
        |> Maybe.andThen .component


linkComponent : Id -> Components.Id -> Motherboard -> Motherboard
linkComponent id component motherboard =
    case Dict.get id motherboard.slots of
        Just slot ->
            let
                slot_ =
                    { slot | component = Just component }

                slots =
                    Dict.insert id slot_ motherboard.slots
            in
                { motherboard | slots = slots }

        Nothing ->
            motherboard


unlinkComponent : Id -> Motherboard -> Motherboard
unlinkComponent id motherboard =
    case Dict.get id motherboard.slots of
        Just slot ->
            case slot.component of
                Just component ->
                    let
                        slot_ =
                            { slot | component = Nothing }

                        slots =
                            Dict.insert id slot_ motherboard.slots

                        networks =
                            Dict.remove component motherboard.networks
                    in
                        { motherboard | slots = slots, networks = networks }

                Nothing ->
                    motherboard

        Nothing ->
            motherboard


getNetwork : Id -> Motherboard -> Maybe Connections.Id
getNetwork id motherboard =
    Dict.get id motherboard.networks


linkNetwork : Components.Id -> Connections.Id -> Motherboard -> Motherboard
linkNetwork id net motherboard =
    { motherboard | networks = Dict.insert id net motherboard.networks }


unlinkNetwork : Components.Id -> Motherboard -> Motherboard
unlinkNetwork id motherboard =
    { motherboard | networks = Dict.remove id motherboard.networks }


getSlots : Motherboard -> Slots
getSlots =
    .slots


getSlotType : Slot -> Components.Type
getSlotType =
    .type_


slotIsEmpty : Slot -> Bool
slotIsEmpty { component } =
    case component of
        Just _ ->
            False

        Nothing ->
            True
