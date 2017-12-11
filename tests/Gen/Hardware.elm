module Gen.Hardware exposing (..)

-- dynamically generated motherboards are hard to produce: it must be
-- consistent with the inventory, this is very hard to archieve with local
-- generators

import Dict exposing (Dict)
import Random.Pcg exposing (Generator, constant, map)
import Fuzz exposing (Fuzzer)
import Gen.Utils exposing (..)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard, Slot)
import Game.Meta.Types.Components as Components exposing (Components, Component)
import Game.Meta.Types.Components.Type as Components
import Game.Meta.Types.Network.Connections as NetConnections exposing (Connections, Connection)
import Game.Servers.Hardware.Models exposing (..)


-- fuzzers


gatewayHardware : Fuzzer Model
gatewayHardware =
    fuzzer genGatewayHardware


endpointHardware : Fuzzer Model
endpointHardware =
    fuzzer genEndpointHardware


motherboard : Fuzzer Motherboard
motherboard =
    fuzzer genMotherboard


shiftMotherboard : Fuzzer Motherboard
shiftMotherboard =
    fuzzer genShiftMotherboard


fullMotherboard : Fuzzer Motherboard
fullMotherboard =
    fuzzer genFullMotherboard


emptyMotherboard : Fuzzer Motherboard
emptyMotherboard =
    fuzzer genEmptyMotherboard



-- generators


genGatewayHardware : Generator Model
genGatewayHardware =
    map Model <| map Just genMotherboard


genEndpointHardware : Generator Model
genEndpointHardware =
    constant { motherboard = Nothing }


genMotherboard : Generator Motherboard
genMotherboard =
    constant <|
        { id =
            Just "component-mob-1"
        , ncs =
            Dict.fromList
                [ ( "component-nic-1", ( "::", "179.154.140.157" ) ) ]
        , slots =
            Dict.fromList
                [ ( "slot-cpu-1"
                  , Slot Components.CPU <| Just "component-cpu-1"
                  )
                , ( "slot-cpu-2"
                  , Slot Components.CPU Nothing
                  )
                , ( "slot-hdd-1"
                  , Slot Components.HDD <| Just "component-hdd-1"
                  )
                , ( "slot-hdd-2"
                  , Slot Components.HDD Nothing
                  )
                , ( "slot-ram-1"
                  , Slot Components.RAM <| Just "component-ram-1"
                  )
                , ( "slot-ram-2"
                  , Slot Components.RAM Nothing
                  )
                , ( "slot-nic-1"
                  , Slot Components.NIC <| Just "component-nic-1"
                  )
                , ( "slot-nic-2"
                  , Slot Components.NIC Nothing
                  )
                ]
        }


genShiftMotherboard : Generator Motherboard
genShiftMotherboard =
    constant <|
        { id =
            Just "component-mob-1"
        , ncs =
            Dict.fromList
                [ ( "component-nic-1", ( "::", "179.154.140.157" ) ) ]
        , slots =
            Dict.fromList
                [ ( "slot-cpu-1"
                  , Slot Components.CPU Nothing
                  )
                , ( "slot-cpu-2"
                  , Slot Components.CPU <| Just "component-cpu-1"
                  )
                , ( "slot-hdd-1"
                  , Slot Components.HDD Nothing
                  )
                , ( "slot-hdd-2"
                  , Slot Components.HDD <| Just "component-hdd-1"
                  )
                , ( "slot-ram-1"
                  , Slot Components.RAM Nothing
                  )
                , ( "slot-ram-2"
                  , Slot Components.RAM <| Just "component-ram-1"
                  )
                , ( "slot-nic-1"
                  , Slot Components.NIC Nothing
                  )
                , ( "slot-nic-2"
                  , Slot Components.NIC <| Just "component-nic-1"
                  )
                ]
        }


genFullMotherboard : Generator Motherboard
genFullMotherboard =
    constant <|
        { id =
            Just "component-mob-1"
        , ncs =
            Dict.fromList
                [ ( "component-nic-1", ( "::", "179.154.140.157" ) )
                , ( "component-nic-2", ( "::", "179.154.140.158" ) )
                ]
        , slots =
            Dict.fromList
                [ ( "slot-cpu-1"
                  , Slot Components.CPU <| Just "component-cpu-1"
                  )
                , ( "slot-cpu-2"
                  , Slot Components.CPU <| Just "component-cpu-2"
                  )
                , ( "slot-hdd-1"
                  , Slot Components.HDD <| Just "component-hdd-1"
                  )
                , ( "slot-hdd-2"
                  , Slot Components.HDD <| Just "component-hdd-2"
                  )
                , ( "slot-ram-1"
                  , Slot Components.RAM <| Just "component-ram-1"
                  )
                , ( "slot-ram-2"
                  , Slot Components.RAM <| Just "component-ram-2"
                  )
                , ( "slot-nic-1"
                  , Slot Components.NIC <| Just "component-nic-1"
                  )
                , ( "slot-nic-2"
                  , Slot Components.NIC <| Just "component-nic-2"
                  )
                ]
        }


genEmptyMotherboard : Generator Motherboard
genEmptyMotherboard =
    constant <|
        { id =
            Just "component-mob-1"
        , ncs =
            Dict.empty
        , slots =
            Dict.fromList
                [ ( "slot-cpu-1", Slot Components.CPU Nothing )
                , ( "slot-cpu-2", Slot Components.CPU Nothing )
                , ( "slot-hdd-1", Slot Components.HDD Nothing )
                , ( "slot-hdd-2", Slot Components.HDD Nothing )
                , ( "slot-ram-1", Slot Components.RAM Nothing )
                , ( "slot-ram-2", Slot Components.RAM Nothing )
                , ( "slot-nic-1", Slot Components.NIC Nothing )
                , ( "slot-nic-2", Slot Components.NIC Nothing )
                ]
        }
