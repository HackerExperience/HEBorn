module Gen.Processes exposing (..)

import Fuzz exposing (Fuzzer)
import Time exposing (Time)
import Random.Pcg
    exposing
        ( Generator
        , constant
        , int
        , float
        , list
        , choices
        , map
        , map2
        , map3
        , andThen
        )
import Random.Pcg.Extra exposing (andMap)
import Game.Servers.Processes.Types.Shared exposing (..)
import Game.Servers.Processes.Types.Local as Local exposing (..)
import Game.Servers.Processes.Types.Remote as Remote exposing (..)
import Game.Servers.Processes.Models as Logs exposing (..)
import Gen.Utils exposing (..)
import Gen.Logs exposing (genLogID, genLogContent)


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


processLocalType : Fuzzer Local.ProcessType
processLocalType =
    fuzzer genLocalProcessType


processRemoteType : Fuzzer Remote.ProcessType
processRemoteType =
    fuzzer genRemoteProcessType


processState : Fuzzer ProcessState
processState =
    fuzzer genProcessState


progress : Fuzzer Float
progress =
    fuzzer genProgress


localProcess : Fuzzer Process
localProcess =
    fuzzer genLocalProcess


localProcessList : Fuzzer (List Process)
localProcessList =
    fuzzer genLocalProcessList


emptyProcesses : Fuzzer Processes
emptyProcesses =
    fuzzer genEmptyProcesses


nonEmptyLocalProcesses : Fuzzer Processes
nonEmptyLocalProcesses =
    fuzzer genNonEmptyLocalProcesses


localProcesses : Fuzzer Processes
localProcesses =
    fuzzer genLocalProcesses


remoteProcess : Fuzzer Process
remoteProcess =
    fuzzer genRemoteProcess


remoteProcessList : Fuzzer (List Process)
remoteProcessList =
    fuzzer genRemoteProcessList


nonEmptyRemoteProcesses : Fuzzer Processes
nonEmptyRemoteProcesses =
    fuzzer genNonEmptyRemoteProcesses


remoteProcesses : Fuzzer Processes
remoteProcesses =
    fuzzer genRemoteProcesses


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


genScope : Generator Scope
genScope =
    [ Local, Global ]
        |> List.map constant
        |> choices


genVersion : Generator Version
genVersion =
    float 1 65


genUsage : Generator Int
genUsage =
    int 0 (10 ^ 9)


genLocalProcessType : Generator Local.ProcessType
genLocalProcessType =
    choices
        [ map Local.Cracker genVersion
        , map3 Local.Decryptor genVersion genFileID genScope
        , map2 Local.Encryptor genVersion genFileID
        , map Local.FileTransference genFileID
        , map3 Local.LogForge genVersion genLogID genLogContent
        , map PassiveFirewall genVersion
        ]


genRemoteProcessType : Generator Remote.ProcessType
genRemoteProcessType =
    choices
        [ constant Remote.Cracker
        , map2 Remote.Decryptor genFileID genScope
        , map Remote.Encryptor genFileID
        , map Remote.FileTransference genFileID
        , map Remote.LogForge genLogID
        ]


genProcessState : Generator ProcessState
genProcessState =
    [ StateStandby, StatePaused, StateComplete ]
        |> List.map constant
        |> choices


genProgress : Generator Float
genProgress =
    percentage


genETA : Generator CompletionDate
genETA =
    float 1420070400 4102444799


genLocalProcessProp : Generator Local.ProcessProp
genLocalProcessProp =
    let
        buildProcessRecord =
            \fID gID nID cID tID priority type_ state eta progress cpuU memU downU upU ->
                { processType = type_
                , priority = priority
                , state = state
                , eta = eta
                , progress = progress
                , fileID = fID
                , gatewayID = gID
                , targetServerID = tID
                , networkID = nID
                , connectionID = cID
                , cpuUsage = cpuU
                , memUsage = memU
                , downloadUsage = downU
                , uploadUsage = upU
                }
    in
        (maybe genFileID)
            |> map buildProcessRecord
            |> andMap genGatewayID
            |> andMap (maybe genNetworkID)
            |> andMap (maybe genConnectionID)
            |> andMap genTargetServerID
            |> andMap genPriority
            |> andMap genLocalProcessType
            |> andMap genProcessState
            |> andMap (maybe genETA)
            |> andMap (maybe genProgress)
            |> andMap genUsage
            |> andMap genUsage
            |> andMap genUsage
            |> andMap genUsage


genRemoteProcessProp : Generator Remote.ProcessProp
genRemoteProcessProp =
    let
        buildProcessRecord =
            \gID nID cID type_ ->
                { processType = type_
                , gatewayID = gID
                , networkID = nID
                , connectionID = cID
                }
    in
        genGatewayID
            |> map buildProcessRecord
            |> andMap (maybe genNetworkID)
            |> andMap (maybe genConnectionID)
            |> andMap genRemoteProcessType


genLocalProcess : Generator Process
genLocalProcess =
    let
        buildProcessRecord =
            \id prop ->
                { id = id
                , prop = prop
                }
    in
        genProcessID
            |> map buildProcessRecord
            |> andMap (map LocalProcess genLocalProcessProp)


genRemoteProcess : Generator Process
genRemoteProcess =
    let
        buildProcessRecord =
            \id prop ->
                { id = id
                , prop = prop
                }
    in
        genProcessID
            |> map buildProcessRecord
            |> andMap (map RemoteProcess genRemoteProcessProp)


genLocalProcessList : Generator (List Process)
genLocalProcessList =
    int 1 8
        |> andThen (\num -> list num genLocalProcess)


genRemoteProcessList : Generator (List Process)
genRemoteProcessList =
    int 1 8
        |> andThen (\num -> list num genRemoteProcess)


genEmptyProcesses : Generator Processes
genEmptyProcesses =
    constant initialProcesses


genNonEmptyLocalProcesses : Generator Processes
genNonEmptyLocalProcesses =
    andThen
        ((List.foldl addProcess initialProcesses) >> constant)
        genLocalProcessList


genNonEmptyRemoteProcesses : Generator Processes
genNonEmptyRemoteProcesses =
    andThen
        ((List.foldl addProcess initialProcesses) >> constant)
        genRemoteProcessList


genLocalProcesses : Generator Processes
genLocalProcesses =
    choices [ genEmptyProcesses, genNonEmptyLocalProcesses ]


genRemoteProcesses : Generator Processes
genRemoteProcesses =
    choices [ genEmptyProcesses, genNonEmptyRemoteProcesses ]


genModel : Generator Processes
genModel =
    genNonEmptyLocalProcesses
