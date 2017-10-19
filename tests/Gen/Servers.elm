module Gen.Servers exposing (..)

import Gen.Filesystem
import Gen.Logs
import Gen.Processes
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
import Game.Network.Types exposing (IP)
import Game.Servers.Models exposing (..)
import Game.Servers.Shared exposing (..)
import Game.Servers.Tunnels.Models as Tunnels
import Game.Notifications.Models as Notifications
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
    map2 (,) unique unique


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
    map (\uid -> GatewayData uid [] Nothing) genServerId


genEndpointOwnership : Generator EndpointData
genEndpointOwnership =
    constant <| EndpointData Nothing Nothing


genServer : Generator Server
genServer =
    genGenericServer genOwnserhip


genGatewayServer : Generator Server
genGatewayServer =
    genGenericServer <| map GatewayOwnership genGatewayOwnership


genEndpointServer : Generator Server
genEndpointServer =
    genGenericServer <| map EndpointOwnership genEndpointOwnership


genGenericServer : Generator Ownership -> Generator Server
genGenericServer gen =
    let
        buildServerRecord ownership nip fs logs proc =
            { name = "Dummy"
            , type_ = Desktop
            , nips = [ nip ]
            , coordinates = Just 0
            , filesystem = fs
            , logs = logs
            , processes = proc
            , tunnels = Tunnels.initialModel
            , ownership =
                ownership
            , notifications =
                Notifications.initialModel
            }
    in
        gen
            |> map buildServerRecord
            |> andMap genServerCId
            |> andMap Gen.Filesystem.genModel
            |> andMap Gen.Logs.genModel
            |> andMap Gen.Processes.genModel


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
