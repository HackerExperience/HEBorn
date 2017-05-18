module Game.Servers.Logs.ModelTest exposing (all)

import Expect
import Gen.Logs as Gen
import Maybe exposing (andThen, withDefault)
import Test exposing (Test, describe)
import Fuzz exposing (tuple, tuple3)
import Utils exposing (andJust)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Game.Servers.Logs.Models exposing (..)


all : Test
all =
    describe "log"
        [ logOperationsTests
        ]


logOperationsTests : Test
logOperationsTests =
    describe "log operations"
        [ describe "add log"
            addLogTests
        , describe "update log"
            updateLogTests
        , describe "delete log"
            deleteLogTests
        ]



--------------------------------------------------------------------------------
-- Add Log
--------------------------------------------------------------------------------


addLogTests : List Test
addLogTests =
    [ describe "generic add log tests"
        addLogGenericTests
    ]


addLogGenericTests : List Test
addLogGenericTests =
    [ fuzz
        (tuple ( Gen.model, Gen.log ))
        "can add a LogEntry but not a NoLog"
      <|
        \( logs, log ) ->
            let
                model =
                    addLog log logs

                expectations =
                    case log of
                        LogEntry log ->
                            Just True

                        NoLog ->
                            Nothing
            in
                log
                    |> getLogID
                    |> andJust (model |> flip logExists)
                    |> Expect.equal expectations
    ]



--------------------------------------------------------------------------------
-- Update Log
--------------------------------------------------------------------------------


updateLogTests : List Test
updateLogTests =
    [ describe "generic update log tests"
        updateLogGenericTests
    ]


updateLogGenericTests : List Test
updateLogGenericTests =
    [ fuzz
        (tuple3 ( Gen.model, Gen.log, Gen.logContent ))
        "update Log contents and noop on NoLog"
      <|
        \( logs, log, content ) ->
            let
                log_ =
                    case log of
                        LogEntry log ->
                            LogEntry { log | content = content }

                        NoLog ->
                            NoLog

                model =
                    logs
                        |> addLog log
                        |> updateLog log_

                expectations =
                    case log of
                        LogEntry _ ->
                            Just content

                        NoLog ->
                            Nothing
            in
                log
                    |> getLogID
                    |> andJust (model |> flip getLogByID)
                    |> andThen getLogContent
                    |> Expect.equal expectations
    ]



--------------------------------------------------------------------------------
-- Delete Log
--------------------------------------------------------------------------------


deleteLogTests : List Test
deleteLogTests =
    [ describe "generic delete log tests"
        deleteLogGenericTests
    ]


deleteLogGenericTests : List Test
deleteLogGenericTests =
    [ fuzz
        (tuple ( Gen.model, Gen.log ))
        "log no longer exists"
      <|
        \( logs, log ) ->
            let
                model =
                    logs
                        |> addLog log
                        |> removeLog log

                expectations =
                    case log of
                        LogEntry log ->
                            Just False

                        NoLog ->
                            Nothing
            in
                log
                    |> getLogID
                    |> andJust (model |> flip logExists)
                    |> Expect.equal expectations
    , fuzz
        (tuple ( Gen.model, Gen.log ))
        "can't delete a non-existing log"
      <|
        \( logs, log ) ->
            logs
                |> removeLog log
                |> Expect.equal logs
    ]
