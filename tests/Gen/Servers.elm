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
        , choice
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
import Gen.Utils exposing (..)


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


serverID : Fuzzer ID
serverID =
    fuzzer genServerID


ip : Fuzzer IP
ip =
    fuzzer genIP


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


genServerID : Generator ID
genServerID =
    unique


{-| TODO: make a true IP generator
-}
genIP : Generator IP
genIP =
    unique


genOwnserhip : Generator Ownership
genOwnserhip =
    choice
        (GatewayOwnership <| GatewayData Nothing [])
        (EndpointOwnership <| EndpointData Nothing Nothing)


genServer : Generator Server
genServer =
    let
        buildServerRecord ip ownership fs logs proc =
            { name = "Dummy"
            , type_ = Desktop
            , nip = ( "::", ip )
            , nips = [ ( "::", ip ) ]
            , coordinates = Just 0
            , filesystem = fs
            , logs = logs
            , processes = proc
            , tunnels = Tunnels.initialModel
            , ownership =
                ownership
            }
    in
        genIP
            |> map buildServerRecord
            |> andMap genOwnserhip
            |> andMap Gen.Filesystem.genModel
            |> andMap Gen.Logs.genModel
            |> andMap Gen.Processes.genModel


genGatewayServer : Generator Server
genGatewayServer =
    let
        buildServerRecord ip fs logs proc =
            { name = "Dummy"
            , type_ = Desktop
            , nip = ( "::", ip )
            , nips = [ ( "::", ip ) ]
            , coordinates = Just 0
            , filesystem = fs
            , logs = logs
            , processes = proc
            , tunnels = Tunnels.initialModel
            , ownership =
                GatewayOwnership <| GatewayData Nothing []
            }
    in
        genIP
            |> map buildServerRecord
            |> andMap Gen.Filesystem.genModel
            |> andMap Gen.Logs.genModel
            |> andMap Gen.Processes.genModel


genEndpointServer : Generator Server
genEndpointServer =
    let
        buildServerRecord ip fs logs proc =
            { name = "Dummy"
            , type_ = Desktop
            , nip = ( "::", ip )
            , nips = [ ( "::", ip ) ]
            , coordinates = Just 0
            , filesystem = fs
            , logs = logs
            , processes = proc
            , tunnels = Tunnels.initialModel
            , ownership =
                GatewayOwnership <| GatewayData Nothing []
            }
    in
        genIP
            |> map buildServerRecord
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
        genServerID
        genServerList


genModel : Generator Model
genModel =
    genNonEmptyModel
