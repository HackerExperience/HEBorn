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


genEmptyModel : Generator Model
genEmptyModel =
    constant initialModel


genNonEmptyModel : Generator Model
genNonEmptyModel =
    let
        reducer =
            (List.foldl (flip addServer) initialModel) >> constant
    in
        andThen reducer genServerDataList


genModel : Generator Model
genModel =
    map (addServer initialModel) genServerData
