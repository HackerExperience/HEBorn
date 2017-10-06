module Decoders.Inventory exposing (..)

import Dict
import Json.Decode as Decode
    exposing
        ( Decoder
        , field
        , andThen
        , map
        , succeed
        , fail
        , dict
        , list
        , string
        , int
        )
import Json.Decode.Pipeline exposing (decode, required)
import Utils.Json.Decode exposing (optionalMaybe, commonError)
import Game.Account.Inventory.Models exposing (..)


iventory : Decoder Model
iventory =
    dict component


component : Decoder Component
component =
    field "type" string
        |> andThen componentType
        |> andThen componentAssembler


slots : Decoder MOBOSlots
slots =
    dict slot


slot : Decoder MOBOSlot
slot =
    decode MOBOSlot
        |> required "internal" string
        |> required "type" (string |> andThen componentType)


componentType : String -> Decoder ComponentType
componentType str =
    case str of
        "ram" ->
            succeed RAM

        "cpu" ->
            succeed CPU

        "hdd" ->
            succeed HDD

        "nic" ->
            succeed NIC

        "mobo" ->
            succeed MOBO

        error ->
            fail <| commonError "mobo_slot_type" error


componentAssembler :
    ComponentType
    -> Decoder Component
componentAssembler type_ =
    case type_ of
        RAM ->
            decode RAMSpec
                |> required "size" int
                |> map ComponentRAM

        CPU ->
            decode CPUSpec
                |> required "clocks" int
                |> required "cores" int
                |> map ComponentCPU

        HDD ->
            decode HDDSpec
                |> required "size" int
                |> map ComponentHDD

        NIC ->
            succeed <| ComponentNIC {}

        MOBO ->
            slots
                |> map MOBOSpec
                |> map ComponentMOBO
