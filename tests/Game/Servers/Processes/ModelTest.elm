module Game.Servers.Processes.ModelTest exposing (all)

import Expect
import Gen.Processes as Gen
import Fuzz exposing (int, tuple)
import Maybe exposing (andThen)
import Test exposing (Test, describe)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Utils exposing (swap, andJust)
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
    [ fuzz
        (tuple ( Gen.emptyProcesses, Gen.process ))
        "can add a process"
      <|
        \( processes, process ) ->
            processes
                |> addProcess process
                |> getProcessByID process.id
                |> Expect.equal (Just process)
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
    [ fuzz
        (tuple ( Gen.processes, Gen.process ))
        "can pause a process"
      <|
        \( model, process ) ->
            model
                |> addProcess process
                |> pauseProcess process
                |> getProcessByID process.id
                |> andThen (\process_ -> Just process_.state)
                |> Expect.equal (Just StatePaused)
    ]



-- --------------------------------------------------------------------------------
-- -- Resume Process
-- --------------------------------------------------------------------------------


resumeProcessTests : List Test
resumeProcessTests =
    [ describe "generic resume process tests"
        resumeProcessGenericTests
    ]


resumeProcessGenericTests : List Test
resumeProcessGenericTests =
    [ fuzz
        (tuple ( Gen.processes, Gen.process ))
        "can resume a paused process"
      <|
        \( processes, process ) ->
            let
                model =
                    processes
                        |> addProcess process
                        |> pauseProcess process

                maybeState =
                    model
                        |> getProcessByID process.id
                        |> andJust ((swap resumeProcess) model 1)
                        |> andThen (getProcessByID process.id)
                        |> andJust (\process_ -> process_.state)
            in
                Expect.equal (Just (StateRunning 1)) maybeState
    , fuzz
        (tuple ( Gen.processes, Gen.process ))
        "can't resume a running process"
      <|
        \( processes, process ) ->
            let
                model =
                    processes
                        |> addProcess process
                        |> resumeProcess process 1
            in
                model
                    |> getProcessByID process.id
                    |> andJust ((swap resumeProcess) model 2)
                    |> andThen (getProcessByID process.id)
                    |> andJust (\process_ -> process_.state)
                    |> Expect.notEqual (Just (StateRunning 2))
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
    [ fuzz
        (tuple ( Gen.processes, Gen.process ))
        "can complete a process"
      <|
        \( processes, process ) ->
            let
                model =
                    processes
                        |> addProcess process
                        |> completeProcess process
            in
                model
                    |> getProcessByID process.id
                    |> andJust (\process_ -> process_.state)
                    |> Expect.equal (Just StateComplete)
    ]



-- --------------------------------------------------------------------------------
-- -- Delete Process
-- --------------------------------------------------------------------------------


deleteProcessTests : List Test
deleteProcessTests =
    [ describe "generic delete process tests"
        deleteProcessGenericTests
    ]


deleteProcessGenericTests : List Test
deleteProcessGenericTests =
    [ fuzz
        (tuple ( Gen.processes, Gen.process ))
        "can delete a process"
      <|
        \( processes, process ) ->
            processes
                |> addProcess process
                |> removeProcess process
                |> getProcessByID process.id
                |> Expect.equal Nothing
    , fuzz
        (tuple ( Gen.processes, Gen.process ))
        "can't delete a non-existing process"
      <|
        \( processes, process ) ->
            processes
                |> removeProcess process
                |> Expect.equal processes
    ]
