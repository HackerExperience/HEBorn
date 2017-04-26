module Game.Servers.Logs.ModelTest exposing (all)

import Expect
import Test exposing (Test, describe)
import Fuzz exposing (int, tuple)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Gen.Logs as Gen
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
    [ fuzz (tuple ( int, int )) "can add a LogEntry but not a NoLog" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                log =
                    Gen.log seed1

                model =
                    addLog (Gen.model seed2) log

                maybeLogExists =
                    case getLogID log of
                        Just id ->
                            Just (logExists model id)

                        Nothing ->
                            Nothing

                expectations =
                    case log of
                        LogEntry log ->
                            Just True

                        NoLog ->
                            Nothing
            in
                Expect.equal expectations maybeLogExists
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
    [ fuzz (tuple ( int, int )) "update Log contents and noop on NoLog" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                content =
                    Gen.content seed2

                log =
                    Gen.log seed1

                log_ =
                    case log of
                        LogEntry log ->
                            LogEntry { log | content = content }

                        NoLog ->
                            NoLog

                model =
                    addLog (Gen.model seed2) log

                model_ =
                    updateLog model log_

                maybeLogID =
                    getLogID log

                maybeLog =
                    case maybeLogID of
                        Just id ->
                            getLogByID model_ id

                        Nothing ->
                            NoLog

                maybeContent =
                    getLogContent maybeLog

                expectations =
                    case log of
                        LogEntry _ ->
                            Just content

                        NoLog ->
                            Nothing
            in
                Expect.equal expectations maybeContent
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
    [ fuzz (tuple ( int, int )) "log no longer exists" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                log =
                    Gen.log seed1

                model =
                    addLog (Gen.model seed2) log

                model_ =
                    removeLog model log

                maybeLogExists =
                    case getLogID log of
                        Just id ->
                            Just (logExists model_ id)

                        Nothing ->
                            Nothing

                expectations =
                    case log of
                        LogEntry log ->
                            Just False

                        NoLog ->
                            Nothing
            in
                Expect.equal expectations maybeLogExists
    , fuzz (tuple ( int, int )) "can't delete a non-existing log" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                log =
                    Gen.log seed1

                model =
                    Gen.model seed2

                model_ =
                    removeLog model log
            in
                Expect.equal model model_
    ]
