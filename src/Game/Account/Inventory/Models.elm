module Game.Account.Inventory.Models
    exposing
        ( Model
        , ComponentID
        , SlotID
        , InternalSlotID
        , Component(..)
        , ComponentType(..)
        , RAMSpec
        , CPUSpec
        , HDDSpec
        , NICSpec
        , MOBOSpec
        , MOBOSlot
        , initialModel
        , get
        , insert
        , remove
        , filterType
        , componentToType
        )

import Dict exposing (Dict)


type alias Model =
    Dict ComponentID Component


type alias ComponentID =
    String


type alias SlotID =
    String


type alias InternalSlotID =
    String


type Component
    = ComponentRAM RAMSpec
    | ComponentCPU CPUSpec
    | ComponentHDD HDDSpec
    | ComponentNIC NICSpec
    | ComponentMOBO MOBOSpec


type ComponentType
    = RAM
    | CPU
    | HDD
    | NIC
    | MOBO


type alias RAMSpec =
    { clock : Int
    , cores : Int
    }


type alias CPUSpec =
    { clock : Int
    , cores : Int
    }


type alias HDDSpec =
    { size : Int
    }


type alias NICSpec =
    {}


type alias MOBOSpec =
    { slots : Dict SlotID MOBOSlot }


type alias MOBOSlot =
    { internalID : InternalSlotID
    , type_ : ComponentType
    }


initialModel : Model
initialModel =
    Dict.empty


get : ComponentID -> Model -> Maybe Component
get =
    Dict.get


insert : ComponentID -> Component -> Model -> Model
insert =
    Dict.insert


remove : ComponentID -> Model -> Model
remove =
    Dict.remove


filterType : ComponentType -> Model -> Model
filterType type_ model =
    let
        filter _ item =
            type_ == componentToType item
    in
        Dict.filter filter model


componentToType : Component -> ComponentType
componentToType component =
    case component of
        ComponentRAM _ ->
            RAM

        ComponentCPU _ ->
            CPU

        ComponentHDD _ ->
            HDD

        ComponentNIC _ ->
            NIC

        ComponentMOBO _ ->
            MOBO
