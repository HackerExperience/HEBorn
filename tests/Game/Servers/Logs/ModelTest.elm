module Game.Servers.Logs.ModelTest exposing (all)

import Expect
import Gen.Logs as Gen
import Test exposing (Test, describe)
import Fuzz exposing (tuple, tuple3)
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
                    add log logs

                expectations =
                    case log of
                        StdLog log ->
                            Just True

                        NoLog ->
                            Nothing
            in
                log
                    |> getID
                    |> Maybe.map (model |> flip exists)
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
                        StdLog log ->
                            StdLog { log | raw = content }

                        NoLog ->
                            NoLog

                model =
                    logs
                        |> add log
                        |> update log_

                expectations =
                    case log of
                        StdLog _ ->
                            Just content

                        NoLog ->
                            Nothing
            in
                log
                    |> getID
                    |> Maybe.map (model |> flip getByID)
                    |> Maybe.andThen getRawContent
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
                        |> add log
                        |> remove log

                expectations =
                    case log of
                        StdLog log ->
                            Just False

                        NoLog ->
                            Nothing
            in
                log
                    |> getID
                    |> Maybe.map (model |> flip exists)
                    |> Expect.equal expectations
    , fuzz
        (tuple ( Gen.model, Gen.log ))
        "can't delete a non-existing log"
      <|
        \( logs, log ) ->
            logs
                |> remove log
                |> Expect.equal logs
    ]
