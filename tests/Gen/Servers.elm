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
        , andThen
        )
import Random.Pcg.Extra exposing (andMap)
import Fuzz exposing (Fuzzer)
import Game.Shared exposing (IP)
import Game.Servers.Models exposing (..)
import Gen.Utils exposing (..)


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


serverID : Fuzzer ServerID
serverID =
    fuzzer genServerID


ip : Fuzzer IP
ip =
    fuzzer genIP


serverData : Fuzzer ServerData
serverData =
    fuzzer genServerData


serverDataList : Fuzzer (List ServerData)
serverDataList =
    fuzzer genServerDataList


server : Fuzzer Server
server =
    fuzzer genServer


emptyServers : Fuzzer Servers
emptyServers =
    fuzzer genEmptyServers


nonEmptyServers : Fuzzer Servers
nonEmptyServers =
    fuzzer genNonEmptyServers


servers : Fuzzer Servers
servers =
    fuzzer genServers


model : Fuzzer Servers
model =
    fuzzer genModel



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genServerID : Generator ServerID
genServerID =
    unique


{-| TODO: make a true IP generator
-}
genIP : Generator IP
genIP =
    unique


genServerData : Generator ServerData
genServerData =
    let
        buildServerDataRecord =
            \id ip fs logs proc ->
                { id = id
                , ip = ip
                , filesystem = fs
                , logs = logs
                , processes = proc
                }
    in
        genServerID
            |> map buildServerDataRecord
            |> andMap genIP
            |> andMap Gen.Filesystem.genModel
            |> andMap Gen.Logs.genModel
            |> andMap Gen.Processes.genModel


genServerDataList : Generator (List ServerData)
genServerDataList =
    andThen (\num -> list num genServerData) (int 1 8)


genServer : Generator Server
genServer =
    map StdServer genServerData


genEmptyServers : Generator Servers
genEmptyServers =
    constant initialServers


genNonEmptyServers : Generator Servers
genNonEmptyServers =
    let
        reducer =
            (List.foldl (flip addServer) initialServers) >> constant
    in
        andThen reducer genServerDataList


genServers : Generator Servers
genServers =
    choices [ genEmptyServers, genNonEmptyServers ]


genModel : Generator Servers
genModel =
    map (addServer initialServers) genServerData
