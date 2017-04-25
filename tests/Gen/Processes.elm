module Gen.Processes exposing (..)

import Game.Network.Models exposing (ConnectionID)
import Game.Servers.Models exposing (ServerID)
import Game.Servers.Processes.Models exposing (..)
import Gen.Filesystem exposing (fileID)
import Gen.Servers
import Gen.Utils exposing (..)


processID : Int -> ProcessID
processID seedInt =
    fuzz1 seedInt processIDSeed


processIDSeed : Seed -> ( ProcessID, Seed )
processIDSeed seed =
    smallStringSeed seed


processType : Int -> ProcessType
processType seedInt =
    fuzz1 seedInt processTypeSeed


processTypeSeed : Seed -> ( ProcessType, Seed )
processTypeSeed seed =
    let
        ( value, seed_ ) =
            (intRangeSeed 0 5 seed)

        result =
            case value of
                1 ->
                    Cracker

                2 ->
                    Decryptor

                3 ->
                    Encryptor

                4 ->
                    FileDownload

                _ ->
                    LogDeleter
    in
        ( result, seed_ )


priority : Int -> ProcessPriority
priority seedInt =
    fuzz1 seedInt prioritySeed


prioritySeed : Seed -> ( ProcessPriority, Seed )
prioritySeed seed =
    (intRangeSeed 0 5 seed)


processState : Int -> ProcessState
processState seedInt =
    fuzz1 seedInt processStateSeed


processStateSeed : Seed -> ( ProcessState, Seed )
processStateSeed seed =
    let
        ( value, seed_ ) =
            (intRangeSeed 1 4 seed)

        result =
            case value of
                1 ->
                    stateRunning seed

                2 ->
                    StateStandby

                3 ->
                    StatePaused

                _ ->
                    StateComplete
    in
        ( result, seed_ )


stateRunning : Seed -> ProcessState
stateRunning seed =
    let
        ( completionDate, _ ) =
            floatRangeSeed 1 60 seed
    in
        StateRunning completionDate


progress : Int -> Progress
progress seedInt =
    fuzz1 seedInt progressSeed


progressSeed : Seed -> ( Float, Seed )
progressSeed seed =
    percentageSeed seed


gatewayID : Int -> ServerID
gatewayID seedInt =
    fuzz1 seedInt gatewayIDSeed


gatewayIDSeed : Seed -> ( ServerID, Seed )
gatewayIDSeed seed =
    Gen.Servers.idSeed seed


networkID : Int -> NetworkID
networkID seedInt =
    fuzz1 seedInt networkIDSeed


networkIDSeed : Seed -> ( NetworkID, Seed )
networkIDSeed seed =
    smallStringSeed seed


targetServerID : Int -> NetworkID
targetServerID seedInt =
    fuzz1 seedInt targetServerIDSeed


targetServerIDSeed : Seed -> ( TargetServerID, Seed )
targetServerIDSeed seed =
    smallStringSeed seed


connectionID : Int -> ConnectionID
connectionID seedInt =
    fuzz1 seedInt connectionIDSeed


connectionIDSeed : Seed -> ( ConnectionID, Seed )
connectionIDSeed seed =
    smallStringSeed seed


process : Int -> Process
process seedInt =
    fuzz1 seedInt processSeed


processSeed : Seed -> ( Process, Seed )
processSeed seed =
    let
        ( seedInt, seed_ ) =
            intSeed seed

        result =
            { id = processID seedInt
            , processType = processType seedInt
            , priority = priority seedInt
            , state = processState seedInt
            , progress = progress seedInt
            , fileID = fileID seedInt
            , gatewayID = gatewayID seedInt
            , targetServerID = targetServerID seedInt
            , networkID = networkID seedInt
            , connectionID = connectionID seedInt
            }
    in
        ( result, seed_ )


processList : Int -> List Process
processList seedInt =
    fuzz1 seedInt processListSeed


processListSeed : Seed -> ( List Process, Seed )
processListSeed seed =
    let
        ( size, seed_ ) =
            intRangeSeed 1 100 seed

        list =
            List.range 1 size

        reducer =
            \_ ( processes, seed ) ->
                let
                    ( process, seed_ ) =
                        processSeed seed
                in
                    ( process :: processes, seed_ )
    in
        List.foldl reducer ( [], seed_ ) list


processesEmpty : Processes
processesEmpty =
    initialProcesses


processes : Int -> Processes
processes seedInt =
    fuzz1 seedInt processesSeed


processesSeed : Seed -> ( Processes, Seed )
processesSeed seed =
    let
        ( processList, seed_ ) =
            processListSeed seed

        processes =
            List.foldl (\p xs -> addProcess xs p) processesEmpty processList
    in
        ( processes, seed_ )
