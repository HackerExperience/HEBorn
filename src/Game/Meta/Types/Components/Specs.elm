module Game.Meta.Types.Components.Specs exposing (..)

import Dict exposing (Dict)
import Game.Meta.Types.Components.Type as Components


-- NOTES: We should migrate to slot type in the future.


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
    -- temporary hadcoded specs
    Dict.fromList
        [ ( "cpu_001", Spec "Threadisaster" "" <| CPU <| MetaCPU 256 )
        , ( "ram_001", Spec "Ram Na Montana" "" <| RAM <| MetaRAM 256 100 )
        , ( "hdd_001", Spec "SemDisk" "" <| HDD <| MetaHDD 1024 1000 )
        , ( "nic_001", Spec "BoringNic" "" <| NIC <| MetaNIC 0 0 )
        , ( "mobo_001", Spec "Mobo1" "" <| MOB <| MetaMOB 1 1 1 1 0 )
        , ( "mobo_002", Spec "Mobo2" "" <| MOB <| MetaMOB 2 1 2 1 1 )
        , ( "mobo_999", Spec "Mobo2" "" <| MOB <| MetaMOB 4 4 4 4 4 )
        ]


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
