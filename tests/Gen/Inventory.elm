module Gen.Inventory exposing (..)

-- a dynamically generated inventory is hard to produce: motherboard and specs
-- must be consistent, this is a very hard thing to do, and tests will usually
-- assume some kind of state, so it's better to generators for that instead

import Dict exposing (Dict)
import Random.Pcg exposing (Generator, constant, map)
import Fuzz exposing (Fuzzer)
import Gen.Utils exposing (..)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard, Slot)
import Game.Meta.Types.Components as Components exposing (Components, Component)
import Game.Meta.Types.Components.Specs as Specs
    exposing
        ( Meta(..)
        , MetaMOB
        , MetaCPU
        , MetaHDD
        , MetaRAM
        , MetaNIC
        , Specs
        , Spec
        )
import Game.Meta.Types.Components.Type as Components
import Game.Meta.Types.Network.Connections as NetConnections exposing (Connections, Connection)
import Game.Inventory.Models exposing (..)


-- fuzzers


inventory : Fuzzer Model
inventory =
    fuzzer genInventory



-- generators


genInventory : Generator Model
genInventory =
    let
        mo1 =
            Spec "Blues Prime B350M"
                "Gaming mid-end motherboard."
                (MOB <| MetaMOB 2 2 2 2 0)

        mo2 =
            Spec "Blues Lite A320"
                "Mainstream low-end motherboard."
                (MOB <| MetaMOB 1 1 1 1 0)

        cpu =
            Spec "Hizen 3 1.3X"
                "Mainstream Zen processor core."
                (CPU <| MetaCPU 3700)

        hdd =
            Spec "World 500gb Cyan"
                "Western but made in china, standard 500gb disk."
                (HDD <| MetaHDD 500000000 6000000)

        ram =
            Spec "SuperX 4gb DDR4 2133mghz"
                "Hyper speed memory."
                (RAM <| MetaRAM 4000000 2133)

        nic =
            Spec "Quaker Aeros"
                "Oatmeal microcontroller network interface card."
                (NIC <| MetaNIC 2000000 1000000)
    in
        constant
            { components =
                Dict.fromList
                    [ ( "component-mob-1", Component mo1 1.0 False )
                    , ( "component-cpu-1", Component cpu 1.0 False )
                    , ( "component-hdd-1", Component hdd 1.0 False )
                    , ( "component-ram-1", Component ram 1.0 False )
                    , ( "component-nic-1", Component nic 1.0 False )
                    , ( "component-mob-2", Component mo2 1.0 True )
                    , ( "component-cpu-2", Component cpu 1.0 True )
                    , ( "component-hdd-2", Component hdd 1.0 True )
                    , ( "component-ram-2", Component ram 1.0 True )
                    , ( "component-nic-2", Component nic 1.0 True )
                    ]
            , ncs =
                Dict.fromList
                    [ ( ( "::", "179.154.140.157" )
                      , Connection "Example 1" False
                      )
                    , ( ( "::", "179.154.140.158" )
                      , Connection "Example 2" True
                      )
                    ]
            , specs =
                Dict.fromList
                    [ ( "cpu-1-spec", cpu )
                    , ( "hdd-1-spec", hdd )
                    , ( "ram-1-spec", ram )
                    , ( "nic-1-spec", nic )
                    ]
            }
