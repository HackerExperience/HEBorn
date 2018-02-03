module Gen.Servers exposing (..)

import Dict exposing (Dict)
import Set
import Gen.Filesystem
import Gen.Logs
import Gen.Processes
import Gen.Hardware
import Random.Pcg
    exposing
        ( Generator
        , constant
        , int
        , list
        , choices
        , map
        , map2
        , andThen
        )
import Random.Pcg.Extra exposing (andMap)
import Fuzz exposing (Fuzzer)
import Game.Meta.Types.Network exposing (IP)
import Game.Servers.Models exposing (..)
import Game.Servers.Shared exposing (..)
import Game.Servers.Tunnels.Models as Tunnels
import Game.Servers.Notifications.Models as Notifications
import Game.Servers.Hardware.Models as Hardware
import Gen.Network exposing (..)
import Gen.Utils exposing (..)


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


serverCId : Fuzzer CId
serverCId =
    fuzzer genServerCId


serverData : Fuzzer Server
serverData =
    fuzzer genServer


serverDataList : Fuzzer (List Server)
serverDataList =
    fuzzer genServerList


server : Fuzzer Server
server =
    fuzzer genServer


emptyModel : Fuzzer Model
emptyModel =
    fuzzer genEmptyModel


nonEmptyModel : Fuzzer Model
nonEmptyModel =
    fuzzer genNonEmptyModel


servers : Fuzzer Model
servers =
    fuzzer genModel


model : Fuzzer Model
model =
    fuzzer genModel



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genServerCId : Generator CId
genServerCId =
    choices
        [ genGatewayCId
        , genEndpointCId
        ]


genGatewayCId : Generator CId
genGatewayCId =
    map GatewayCId genServerId


genEndpointCId : Generator CId
genEndpointCId =
    map EndpointCId genNip


genServerId : Generator Id
genServerId =
    unique


genOwnserhip : Generator Ownership
genOwnserhip =
    choices
        [ map GatewayOwnership genGatewayOwnership
        , map EndpointOwnership genEndpointOwnership
        ]


genGatewayOwnership : Generator GatewayData
genGatewayOwnership =
    constant <| GatewayData Set.empty Nothing


genEndpointOwnership : Generator EndpointData
genEndpointOwnership =
    constant <| EndpointData Nothing


genServer : Generator Server
genServer =
    genGenericServer genOwnserhip Gen.Hardware.genGatewayHardware


genGatewayServer : Generator Server
genGatewayServer =
    Gen.Hardware.genGatewayHardware
        |> genGenericServer (map GatewayOwnership genGatewayOwnership)


genEndpointServer : Generator Server
genEndpointServer =
    Gen.Hardware.genEndpointHardware
        |> genGenericServer (map EndpointOwnership genEndpointOwnership)


genGenericServer : Generator Ownership -> Generator Hardware.Model -> Generator Server
genGenericServer genOwnserhip genHardware =
    let
        buildServerRecord ownership nip fs logs proc hardware =
            { name = "Dummy"
            , type_ = Desktop
            , nips = [ nip ]
            , activeNIP = nip
            , coordinates = Just 0
            , mainStorage = "storage"
            , storages =
                Dict.fromList [ ( "storage", Storage "Storage" fs ) ]
            , logs = logs
            , bounce = Nothing
            , processes = proc
            , tunnels = Tunnels.initialModel
            , ownership =
                ownership
            , notifications =
                Notifications.initialModel
            , hardware =
                hardware
            }
    in
        genOwnserhip
            |> map buildServerRecord
            |> andMap genNip
            |> andMap Gen.Filesystem.genModel
            |> andMap Gen.Logs.genModel
            |> andMap Gen.Processes.genModel
            |> andMap genHardware


genServerList : Generator (List Server)
genServerList =
    andThen (\num -> list num genServer) (int 8 10)


genEmptyModel : Generator Model
genEmptyModel =
    constant initialModel


genNonEmptyModel : Generator Model
genNonEmptyModel =
    map2 (\id -> List.foldl (insert id) initialModel)
        genServerCId
        genServerList


genModel : Generator Model
genModel =
    genNonEmptyModel
