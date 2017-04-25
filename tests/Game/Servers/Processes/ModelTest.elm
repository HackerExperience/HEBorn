module Game.Servers.Processes.ModelTest exposing (all)

import Expect
import Test exposing (Test, describe)
import Fuzz exposing (int, tuple)
import Maybe exposing (andThen)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Gen.Processes as Gen
import Game.Servers.Processes.Models exposing (..)


all : Test
all =
    describe "process"
        [ processOperationsTests
        ]


processOperationsTests : Test
processOperationsTests =
    describe "process operations"
        [ describe "add process"
            addProcessTests
        , describe "pause process"
            pauseProcessTests
        , describe "resume process"
            resumeProcessTests
        , describe "complete process"
            completeProcessTests
        , describe "delete process"
            deleteProcessTests
        ]



--------------------------------------------------------------------------------
-- Add Process
--------------------------------------------------------------------------------


addProcessTests : List Test
addProcessTests =
    [ describe "generic add process tests"
        addProcessGenericTests
    ]


addProcessGenericTests : List Test
addProcessGenericTests =
    [ fuzz int "can add a process" <|
        \seed ->
            let
                process =
                    Gen.process seed

                processes =
                    Gen.processesEmpty

                processes_ =
                    addProcess processes process

                result =
                    getProcessByID processes_ process.id
            in
                Expect.equal (Just process) result
    ]



--------------------------------------------------------------------------------
-- Pause Process
--------------------------------------------------------------------------------


pauseProcessTests : List Test
pauseProcessTests =
    [ describe "generic pause process tests"
        pauseProcessGenericTests
    ]


pauseProcessGenericTests : List Test
pauseProcessGenericTests =
    [ fuzz int "can pause a process" <|
        \seed ->
            let
                -- REVIEW: this code could be refactored to a better form by
                -- moving the collection to the last param, this is also a
                -- pattern on functional programming:
                --
                --   seed
                --     |> Gen.processes
                --     |> addProcess process
                --     |> pauseProcess process
                process =
                    Gen.process seed

                processes =
                    pauseProcess
                        (addProcess (Gen.processes seed) process)
                        process

                maybeProcess =
                    getProcessByID processes process.id

                maybeState =
                    case maybeProcess of
                        Just process_ ->
                            Just process_.state

                        Nothing ->
                            Nothing
            in
                Expect.equal (Just StatePaused) maybeState
    ]



--------------------------------------------------------------------------------
-- Resume Process
--------------------------------------------------------------------------------


resumeProcessTests : List Test
resumeProcessTests =
    [ describe "generic resume process tests"
        resumeProcessGenericTests
    ]


resumeProcessGenericTests : List Test
resumeProcessGenericTests =
    [ fuzz int "can resume a paused process" <|
        \seed ->
            let
                proc =
                    Gen.process seed

                procs =
                    pauseProcess
                        (addProcess (Gen.processes seed) proc)
                        proc

                -- FIXME: this won't be that awkward after we move our
                -- collections to the last param
                maybeState =
                    proc.id
                        |> getProcessByID procs
                        |> andThen (\proc -> Just (resumeProcess procs proc 1))
                        |> andThen (\procs -> getProcessByID procs proc.id)
                        |> andThen (\proc -> Just proc.state)
            in
                Expect.equal (Just (StateRunning 1)) maybeState
    , fuzz int "can't resume a running process" <|
        \seed ->
            let
                proc =
                    Gen.process seed

                procs =
                    resumeProcess
                        (addProcess (Gen.processes seed) proc)
                        proc
                        1

                -- FIXME: this won't be that awkward after we move our
                -- collections to the last param
                maybeState =
                    proc.id
                        |> getProcessByID procs
                        |> andThen (\proc -> Just (resumeProcess procs proc 2))
                        |> andThen (\procs -> getProcessByID procs proc.id)
                        |> andThen (\proc -> Just proc.state)
            in
                Expect.notEqual (Just (StateRunning 2)) maybeState
    ]



--------------------------------------------------------------------------------
-- Complete Process
--------------------------------------------------------------------------------


completeProcessTests : List Test
completeProcessTests =
    [ describe "generic complete process tests"
        completeProcessGenericTests
    ]


completeProcessGenericTests : List Test
completeProcessGenericTests =
    [ fuzz int "can complete a process" <|
        \seed ->
            let
                process =
                    Gen.process seed

                processes =
                    completeProcess
                        (addProcess (Gen.processes seed) process)
                        process

                maybeProcess =
                    getProcessByID processes process.id

                maybeState =
                    case maybeProcess of
                        Just process_ ->
                            Just process_.state

                        Nothing ->
                            Nothing
            in
                Expect.equal (Just StateComplete) maybeState
    ]



--------------------------------------------------------------------------------
-- Delete Process
--------------------------------------------------------------------------------


deleteProcessTests : List Test
deleteProcessTests =
    [ describe "generic delete process tests"
        deleteProcessGenericTests
    ]


deleteProcessGenericTests : List Test
deleteProcessGenericTests =
    [ fuzz int "can delete a process" <|
        \seed ->
            let
                process =
                    Gen.process seed

                processes =
                    addProcess Gen.processesEmpty process

                processes_ =
                    removeProcess processes process

                result =
                    getProcessByID processes_ process.id
            in
                Expect.equal Nothing result
    , fuzz int "can delete a non-existing process" <|
        \seed ->
            let
                process =
                    Gen.process seed

                processes =
                    Gen.processes seed

                processes_ =
                    removeProcess processes process
            in
                Expect.equal processes processes_
    ]
