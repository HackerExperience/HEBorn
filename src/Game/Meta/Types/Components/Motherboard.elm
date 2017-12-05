module Game.Meta.Types.Components.Motherboard exposing (..)

import Dict exposing (Dict)
import Json.Encode as Encode exposing (Value)
import Utils.Maybe as Maybe
import Game.Meta.Types.Components.Type as Components
import Game.Meta.Types.Components as Components exposing (Components)
import Game.Meta.Types.Network.Connections as Connections exposing (Connections)


type alias Motherboard =
    { id : Maybe Components.Id
    , ncs : NetConnections
    , slots : Slots
    }


type alias NetConnections =
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
    , ncs = Dict.empty
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
    let
        maybeSlot =
            Dict.get id motherboard.slots

        maybeComponent =
            Maybe.andThen .component maybeSlot
    in
        case Maybe.uncurry maybeSlot maybeComponent of
            Just ( slot, component ) ->
                let
                    slot_ =
                        { slot | component = Nothing }

                    slots =
                        Dict.insert id slot_ motherboard.slots

                    ncs =
                        Dict.remove component motherboard.ncs
                in
                    { motherboard | slots = slots, ncs = ncs }

            Nothing ->
                motherboard


getNC : Components.Id -> Motherboard -> Maybe Connections.Id
getNC id motherboard =
    Dict.get id motherboard.ncs


linkNC : Components.Id -> Connections.Id -> Motherboard -> Motherboard
linkNC id net motherboard =
    { motherboard | ncs = Dict.insert id net motherboard.ncs }


unlinkNC : Components.Id -> Motherboard -> Motherboard
unlinkNC id motherboard =
    { motherboard | ncs = Dict.remove id motherboard.ncs }


getSlot : Id -> Motherboard -> Maybe Slot
getSlot id motherboard =
    Dict.get id <| getSlots motherboard


getSlots : Motherboard -> Slots
getSlots =
    .slots


getSlotType : Slot -> Components.Type
getSlotType =
    .type_


getSlotComponent : Slot -> Maybe Components.Id
getSlotComponent =
    .component


slotIsEmpty : Slot -> Bool
slotIsEmpty { component } =
    case component of
        Just _ ->
            False

        Nothing ->
            True


getNCs : Motherboard -> NetConnections
getNCs =
    .ncs


encode : Motherboard -> Value
encode motherboard =
    case motherboard.id of
        Just id ->
            Encode.object
                [ ( "motherboard_id", Encode.string id )
                , ( "slots", encodeSlots motherboard.slots )
                , ( "network_connections", encodeNCs motherboard.ncs )
                ]

        Nothing ->
            Encode.object []


encodeSlots : Slots -> Value
encodeSlots =
    let
        reducer id slot list =
            case slot.component of
                Just component ->
                    ( id, Encode.string component ) :: list

                Nothing ->
                    ( id, Encode.null ) :: list
    in
        Dict.foldl reducer [] >> Encode.object


encodeNCs : NetConnections -> Value
encodeNCs =
    let
        encode ( id, ip ) =
            Encode.object
                [ ( "ip", Encode.string ip )
                , ( "network_id", Encode.string id )
                ]

        reducer component network list =
            ( component, encode network ) :: list
    in
        Dict.foldl reducer [] >> Encode.object
