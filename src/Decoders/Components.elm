module Decoders.Components exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
    exposing
        ( Decoder
        , succeed
        , fail
        , bool
        , int
        , float
        , string
        , dict
        , field
        , map
        , andThen
        )
import Json.Decode.Pipeline exposing (decode, required, optional, custom)
import Utils.Json.Decode exposing (commonError)
import Game.Meta.Types.Components exposing (..)
import Game.Meta.Types.Components.Type exposing (Type(..))
import Game.Meta.Types.Components.Specs as Specs exposing (Spec, Specs)


components : Specs -> Decoder Components
components specs =
    dict <| component specs


component : Specs -> Decoder Component
component specs_ =
    decode Component
        |> custom (getSpec specs_)
        |> required "durability" float
        |> required "used?" bool


getSpec : Specs -> Decoder Spec
getSpec =
    let
        decoder specs id =
            case Dict.get id specs of
                Just spec ->
                    succeed spec

                Nothing ->
                    fail <| commonError "spec" id
    in
        decoder >> flip andThen (field "spec_id" string)


type_ : Decoder Type
type_ =
    let
        decoder t =
            case t of
                "cpu" ->
                    succeed CPU

                "hdd" ->
                    succeed HDD

                "ram" ->
                    succeed RAM

                "nic" ->
                    succeed NIC

                "usb" ->
                    succeed USB

                "motherboard" ->
                    succeed MOB

                _ ->
                    fail <| commonError "type" t
    in
        andThen decoder string


specs : Decoder Specs
specs =
    dict spec


spec : Decoder Spec
spec =
    decode Spec
        |> optional "name" string "PENDING"
        |> optional "description" string "PENDING"
        |> custom meta


meta : Decoder Specs.Meta
meta =
    let
        cpu =
            decode Specs.MetaCPU
                |> required "clock" int
                |> map Specs.CPU

        hdd =
            decode Specs.MetaHDD
                |> required "size" int
                |> required "iops" int
                |> map Specs.HDD

        ram =
            decode Specs.MetaRAM
                |> required "size" int
                |> required "frequency" int
                |> map Specs.RAM

        nic =
            decode Specs.MetaNIC
                |> required "uplink" int
                |> required "downlink" int
                |> map Specs.NIC

        usb =
            decode Specs.MetaUSB
                |> required "size" int
                |> map Specs.USB

        mob =
            decode Specs.MetaMOB
                |> required "cpu" int
                |> required "hdd" int
                |> required "ram" int
                |> required "nic" int
                |> required "usb" int
                |> map Specs.MOB

        meta t =
            case t of
                "cpu" ->
                    cpu

                "hdd" ->
                    hdd

                "ram" ->
                    ram

                "nic" ->
                    nic

                "usb" ->
                    usb

                "motherboard" ->
                    mob

                _ ->
                    fail <| commonError "custom (spec meta)" t
    in
        andThen meta <| field "type" string
