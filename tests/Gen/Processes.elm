module Gen.Processes exposing (..)

import Fuzz exposing (Fuzzer)
import Random.Pcg
    exposing
        ( Generator
        , constant
        , int
        , float
        , list
        , choices
        , map
        , andThen
        )
import Random.Pcg.Extra exposing (andMap)
import Game.Servers.Processes.Models exposing (..)
import Gen.Utils exposing (..)


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


processID : Fuzzer ProcessID
processID =
    fuzzer genProcessID


gatewayID : Fuzzer GatewayID
gatewayID =
    fuzzer genGatewayID


networkID : Fuzzer NetworkID
networkID =
    fuzzer genNetworkID


targetServerID : Fuzzer TargetServerID
targetServerID =
    fuzzer genTargetServerID


connectionID : Fuzzer ConnectionID
connectionID =
    fuzzer genConnectionID


priority : Fuzzer ProcessPriority
priority =
    fuzzer genPriority


processType : Fuzzer ProcessType
processType =
    fuzzer genProcessType


processRunning : Fuzzer ProcessState
processRunning =
    fuzzer genProcessRunning


processState : Fuzzer ProcessState
processState =
    fuzzer genProcessState


progress : Fuzzer Float
progress =
    fuzzer genProgress


process : Fuzzer Process
process =
    fuzzer genProcess


processList : Fuzzer (List Process)
processList =
    fuzzer genProcessList


emptyProcesses : Fuzzer Processes
emptyProcesses =
    fuzzer genEmptyProcesses


nonEmptyProcesses : Fuzzer Processes
nonEmptyProcesses =
    fuzzer genNonEmptyProcesses


processes : Fuzzer Processes
processes =
    fuzzer genProcesses


model : Fuzzer Processes
model =
    fuzzer genModel



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genProcessID : Generator ProcessID
genProcessID =
    unique


{-| Remove this as soon as Gen.Filesystem gets updated
-}
genFileID : Generator String
genFileID =
    unique


genGatewayID : Generator GatewayID
genGatewayID =
    unique


genNetworkID : Generator NetworkID
genNetworkID =
    unique


genTargetServerID : Generator TargetServerID
genTargetServerID =
    unique


genConnectionID : Generator ConnectionID
genConnectionID =
    unique


genPriority : Generator ProcessPriority
genPriority =
    int 0 5


genProcessType : Generator ProcessType
genProcessType =
    [ Cracker, Decryptor, Encryptor, FileDownload, LogDeleter ]
        |> List.map constant
        |> choices


genProcessRunning : Generator ProcessState
genProcessRunning =
    float 1 60
        |> map StateRunning


genProcessState : Generator ProcessState
genProcessState =
    [ StateStandby, StatePaused, StateComplete ]
        |> List.map constant
        |> (::) genProcessRunning
        |> choices


genProgress : Generator Float
genProgress =
    percentage


genProcess : Generator Process
genProcess =
    let
        buildProcessRecord =
            \id fID gID nID cID tID priority type_ state progress ->
                { id = id
                , fileID = fID
                , gatewayID = gID
                , networkID = nID
                , connectionID = cID
                , targetServerID = tID
                , priority = priority
                , processType = type_
                , state = state
                , progress = progress
                }
    in
        genProcessID
            |> map buildProcessRecord
            |> andMap genFileID
            |> andMap genGatewayID
            |> andMap genNetworkID
            |> andMap genConnectionID
            |> andMap genTargetServerID
            |> andMap genPriority
            |> andMap genProcessType
            |> andMap genProcessState
            |> andMap genProgress


genProcessList : Generator (List Process)
genProcessList =
    int 1 8
        |> andThen (\num -> list num genProcess)


genEmptyProcesses : Generator Processes
genEmptyProcesses =
    constant initialProcesses


genNonEmptyProcesses : Generator Processes
genNonEmptyProcesses =
    andThen
        ((List.foldl addProcess initialProcesses) >> constant)
        genProcessList


genProcesses : Generator Processes
genProcesses =
    choices [ genEmptyProcesses, genNonEmptyProcesses ]


genModel : Generator Processes
genModel =
    genNonEmptyProcesses
