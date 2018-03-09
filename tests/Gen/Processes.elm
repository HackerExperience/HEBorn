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
import Game.Servers.Processes.Shared as Processes exposing (..)
import Game.Servers.Shared as Servers
import Game.Servers.Logs.Models as Logs
import Gen.Network as GenNetwork
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


partialProcess : Fuzzer Process
partialProcess =
    fuzzer genPartialProcess


type_ : Fuzzer Type
type_ =
    fuzzer genType


encryptorContent : Fuzzer EncryptorContent
encryptorContent =
    fuzzer genEncryptorContent


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


date : Fuzzer CompletionDate
date =
    fuzzer genDate


fileID : Fuzzer FileID
fileID =
    fuzzer genFileID


logID : Fuzzer Logs.ID
logID =
    fuzzer genLogID



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
        |> andMap GenNetwork.genId
        |> andMap GenNetwork.genIp


genFullProcess : Generator Process
genFullProcess =
    genType
        |> map Process
        |> andMap (map Full genFullAccess)
        |> andMap genState
        |> andMap (maybe genProcessFile)
        |> andMap (maybe genProgress)
        |> andMap GenNetwork.genId
        |> andMap GenNetwork.genIp


genPartialProcess : Generator Process
genPartialProcess =
    genType
        |> map Process
        |> andMap (map Partial genPartialAccess)
        |> andMap genState
        |> andMap (maybe genProcessFile)
        |> andMap (maybe genProgress)
        |> andMap GenNetwork.genId
        |> andMap GenNetwork.genIp


genType : Generator Type
genType =
    choices
        [ constant Cracker
        , constant Decryptor
        , map Encryptor genEncryptorContent
        , constant FileTransference
        , constant PassiveFirewall
        ]


genEncryptorContent : Generator EncryptorContent
genEncryptorContent =
    map EncryptorContent genLogID


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
        |> andMap (maybe genConnectionID)
        |> andMap (maybe genProcessFile)


genPartialAccess : Generator PartialAccess
genPartialAccess =
    map PartialAccess (maybe genConnectionID)
        |> andMap (maybe genConnectionID)


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
    constant ( 0, 0 )


genConnectionID : Generator ConnectionID
genConnectionID =
    unique


genState : Generator State
genState =
    choices
        [ constant Starting
        , constant Running
        , constant Paused
        , constant Succeeded
        , constant <| Failed Unknown
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
    map3 Progress genDate (maybe genDate) (maybe genPercentage)


genPercentage : Generator Percentage
genPercentage =
    float 0.0 1.0


genDate : Generator CompletionDate
genDate =
    float 1420070400 4102444799


genLogID : Generator Logs.ID
genLogID =
    unique
