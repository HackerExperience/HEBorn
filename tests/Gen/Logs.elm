module Gen.Logs exposing (..)

import Time exposing (Time)
import Fuzz exposing (Fuzzer)
import Random.Pcg
    exposing
        ( Generator
        , constant
        , map
        , map3
        , choices
        , andThen
        , list
        , int
        , float
        )
import Random.Pcg.Extra exposing (andMap)
import Gen.Utils exposing (..)
import Game.Servers.Logs.Models as Logs exposing (..)


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


logID : Fuzzer ID
logID =
    fuzzer genLogID


logContent : Fuzzer RawContent
logContent =
    fuzzer genLogContent


logEntry : Fuzzer Log
logEntry =
    fuzzer genLogEntry


noLog : Fuzzer Log
noLog =
    fuzzer genNoLog


log : Fuzzer Log
log =
    fuzzer genLog


logList : Fuzzer (List Log)
logList =
    fuzzer genLogList


emptyLogs : Fuzzer Logs
emptyLogs =
    fuzzer genEmptyLogs


nonEmptyLogs : Fuzzer Logs
nonEmptyLogs =
    fuzzer genNonEmptyLogs


logs : Fuzzer Logs
logs =
    fuzzer genLogs


model : Fuzzer Logs
model =
    fuzzer genModel



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genLogID : Generator ID
genLogID =
    unique


genLogContent : Generator RawContent
genLogContent =
    stringRange 0 32


genLogData : Generator StdData
genLogData =
    let
        raw =
            genLogContent
    in
        genLogID
            |> map StdData
            |> andMap genStatus
            |> andMap genTimestamp
            |> andMap raw
            |> andMap (constant (Invalid ""))
            |> andMap genEvent


genLogEntry : Generator Log
genLogEntry =
    map StdLog genLogData


genNoLog : Generator Log
genNoLog =
    constant NoLog


genLog : Generator Log
genLog =
    choices [ genLogEntry, genNoLog ]


genStatus : Generator Status
genStatus =
    [ StatusNormal, Cryptographed ]
        |> List.map constant
        |> choices


genEvent : Generator Event
genEvent =
    [ NoEvent, EventRecentlyFound, EventRecentlyCreated ]
        |> List.map constant
        |> choices


genLogList : Generator (List Log)
genLogList =
    andThen (genLog |> flip list) (int 1 10)


genEmptyLogs : Generator Logs
genEmptyLogs =
    constant initialLogs


genNonEmptyLogs : Generator Logs
genNonEmptyLogs =
    andThen ((List.foldl Logs.add initialLogs) >> constant) genLogList


genLogs : Generator Logs
genLogs =
    choices [ genEmptyLogs, genNonEmptyLogs ]


genModel : Generator Logs
genModel =
    genNonEmptyLogs


genTimestamp : Generator Time
genTimestamp =
    float 1420070400 4102444799
