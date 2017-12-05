module Game.Meta.Types.Components.Specs exposing (..)

import Dict exposing (Dict)
import Game.Meta.Types.Components.Type as Components


type alias Id =
    String


type alias Specs =
    Dict Id Spec


type alias Spec =
    { name : String
    , description : String
    , meta : Meta
    }


type Meta
    = CPU MetaCPU
    | HDD MetaHDD
    | RAM MetaRAM
    | NIC MetaNIC
    | USB MetaUSB
    | MOB MetaMOB


type alias MetaCPU =
    { clock : Int }


type alias MetaHDD =
    { size : Int
    , iops : Int
    }


type alias MetaRAM =
    { size : Int
    , frequency : Int
    }


type alias MetaNIC =
    { uplink : Int
    , downlink : Int
    }


type alias MetaUSB =
    { size : Int }


type alias MetaMOB =
    { cpu : Int
    , hdd : Int
    , ram : Int
    , nic : Int
    , usb : Int
    }


empty : Specs
empty =
    Dict.empty


render : Spec -> List ( String, String )
render spec =
    case spec.meta of
        CPU { clock } ->
            [ ( "clock", toString clock ) ]

        HDD { size, iops } ->
            [ ( "size", toString size )
            , ( "iops", toString iops )
            ]

        RAM { size, frequency } ->
            [ ( "size", toString size )
            , ( "frequency", toString frequency )
            ]

        NIC { uplink, downlink } ->
            [ ( "uplink", toString uplink )
            , ( "downlink", toString downlink )
            ]

        USB { size } ->
            [ ( "size", toString size ) ]

        MOB { cpu, hdd, ram, nic, usb } ->
            [ ( "cpu", toString cpu )
            , ( "hdd", toString hdd )
            , ( "ram", toString ram )
            , ( "nic", toString nic )
            , ( "usb", toString usb )
            ]


get : Id -> Specs -> Maybe Spec
get =
    Dict.get


getName : Spec -> String
getName =
    .name


getDescription : Spec -> String
getDescription =
    .description


toType : Spec -> Components.Type
toType { meta } =
    case meta of
        CPU _ ->
            Components.CPU

        HDD _ ->
            Components.HDD

        RAM _ ->
            Components.RAM

        NIC _ ->
            Components.NIC

        USB _ ->
            Components.USB

        MOB _ ->
            Components.MOB
