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
        , sample
        , map
        , map2
        , map3
        , andThen
        )
import Random.Pcg.Extra exposing (andMap)
import Game.Servers.Tunnels.Models exposing (ConnectionID)
import Game.Servers.Processes.Models as Processes exposing (..)
import Gen.Utils exposing (..)
import Gen.Logs as Logs


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


model : Fuzzer Model
model =
    fuzzer genModel


processes : Fuzzer (List ( ID, Process ))
processes =
    fuzzer genProcesses


pair : Fuzzer ( ID, Process )
pair =
    fuzzer genPair


id : Fuzzer ID
id =
    fuzzer genID


process : Fuzzer Process
process =
    fuzzer genProcess


fullProcess : Fuzzer Process
fullProcess =
    fuzzer genFullProcess


type_ : Fuzzer Type
type_ =
    fuzzer genType


access : Fuzzer Access
access =
    fuzzer genAccess


fullAccess : Fuzzer FullAccess
fullAccess =
    fuzzer genFullAccess


partialAccess : Fuzzer PartialAccess
partialAccess =
    fuzzer genPartialAccess


priority : Fuzzer Priority
priority =
    fuzzer genPriority


resourcesUsage : Fuzzer ResourcesUsage
resourcesUsage =
    fuzzer genResourcesUsage


usage : Fuzzer Usage
usage =
    fuzzer genUsage


connectionID : Fuzzer ConnectionID
connectionID =
    fuzzer genConnectionID


originConnection : Fuzzer ( ServerID, ConnectionID )
originConnection =
    fuzzer genOriginConnection


state : Fuzzer State
state =
    fuzzer genState


version : Fuzzer Version
version =
    fuzzer genVersion


progress : Fuzzer Progress
progress =
    fuzzer genProgress


percentage : Fuzzer Percentage
percentage =
    fuzzer genPercentage


completionDate : Fuzzer CompletionDate
completionDate =
    fuzzer genCompletionDate


fileID : Fuzzer FileID
fileID =
    fuzzer genFileID


serverID : Fuzzer ServerID
serverID =
    fuzzer genServerID



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genModel : Generator Model
genModel =
    genProcesses
        |> andThen (List.foldl (uncurry insert) initialModel >> constant)


genProcesses : Generator (List ( ID, Process ))
genProcesses =
    andThen (genPair |> flip list) (int 1 10)


genPair : Generator ( ID, Process )
genPair =
    map2 (,) genID genProcess


genID : Generator ID
genID =
    unique


genProcess : Generator Process
genProcess =
    genType
        |> map Process
        |> andMap genAccess
        |> andMap genState
        |> andMap (maybe genProcessFile)
        |> andMap (maybe genProgress)
        |> andMap genServerID


genFullProcess : Generator Process
genFullProcess =
    genType
        |> map Process
        |> andMap (map Full genFullAccess)
        |> andMap genState
        |> andMap (maybe genProcessFile)
        |> andMap (maybe genProgress)
        |> andMap genServerID


genType : Generator Type
genType =
    [ Cracker
    , Decryptor
    , Encryptor
    , FileTransference
    , PassiveFirewall
    ]
        |> List.map constant
        |> choices


genAccess : Generator Access
genAccess =
    choices
        [ map Full genFullAccess
        , map Partial genPartialAccess
        ]


genFullAccess : Generator FullAccess
genFullAccess =
    unique
        |> map FullAccess
        |> andMap genPriority
        |> andMap genResourcesUsage
        |> andMap (maybe genConnectionID)


genPartialAccess : Generator PartialAccess
genPartialAccess =
    map PartialAccess (maybe genOriginConnection)


genPriority : Generator Priority
genPriority =
    [ Lowest
    , Low
    , Normal
    , High
    , Highest
    ]
        |> List.map constant
        |> choices


genResourcesUsage : Generator ResourcesUsage
genResourcesUsage =
    genUsage
        |> map ResourcesUsage
        |> andMap genUsage
        |> andMap genUsage
        |> andMap genUsage


genUsage : Generator Usage
genUsage =
    constant ( 0, "" )


genConnectionID : Generator ConnectionID
genConnectionID =
    unique


genOriginConnection : Generator ( ServerID, ConnectionID )
genOriginConnection =
    map2 (,) unique genConnectionID


genState : Generator State
genState =
    choices
        [ constant Starting
        , constant Running
        , constant Paused
        , constant Succeeded
        , constant <| Failed (Just "")
        ]


genProcessFile : Generator ProcessFile
genProcessFile =
    (maybe genFileID)
        |> map ProcessFile
        |> andMap (maybe genVersion)
        |> andMap genFileName


genFileID : Generator FileID
genFileID =
    unique


genVersion : Generator Float
genVersion =
    float 0.1 100.0


genFileName : Generator FileName
genFileName =
    unique


genProgress : Generator Progress
genProgress =
    map2 (,) genPercentage (maybe genCompletionDate)


genPercentage : Generator Percentage
genPercentage =
    float 0.0 1.0


genCompletionDate : Generator CompletionDate
genCompletionDate =
    float 1420070400 4102444799


genServerID : Generator ServerID
genServerID =
    unique
