module Game.Servers.Processes.ModelTest exposing (all)

import Expect
import Utils exposing (swap, andJust)
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

                result =
                    Gen.processesEmpty
                        |> addProcess process
                        |> getProcessByID process.id
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
                process =
                    Gen.process seed

                maybeState =
                    seed
                        |> Gen.processes
                        |> addProcess process
                        |> pauseProcess process
                        |> getProcessByID process.id
                        |> andThen (\process_ -> Just process_.state)
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
                process =
                    Gen.process seed

                processes =
                    seed
                        |> Gen.processes
                        |> addProcess process
                        |> pauseProcess process

                maybeState =
                    processes
                        |> getProcessByID process.id
                        |> andJust ((swap resumeProcess) processes 1)
                        |> andThen (getProcessByID process.id)
                        |> andJust (\process_ -> process_.state)
            in
                Expect.equal (Just (StateRunning 1)) maybeState
    , fuzz int "can't resume a running process" <|
        \seed ->
            let
                process =
                    Gen.process seed

                processes =
                    seed
                        |> Gen.processes
                        |> addProcess process
                        |> resumeProcess process 1

                maybeState =
                    processes
                        |> getProcessByID process.id
                        |> andJust ((swap resumeProcess) processes 2)
                        |> andThen (getProcessByID process.id)
                        |> andJust (\process_ -> process_.state)
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
                    seed
                        |> Gen.processes
                        |> addProcess process
                        |> completeProcess process

                maybeState =
                    processes
                        |> getProcessByID process.id
                        |> andJust (\process_ -> process_.state)
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
                    Gen.processesEmpty
                        |> addProcess process
                        |> removeProcess process
            in
                Expect.equal Nothing (getProcessByID process.id processes)
    , fuzz int "can't delete a non-existing process" <|
        \seed ->
            let
                processes =
                    Gen.processes seed

                processes_ =
                    removeProcess (Gen.process seed) processes
            in
                Expect.equal processes processes_
    ]
