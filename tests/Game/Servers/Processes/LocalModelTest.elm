module Game.Servers.Processes.LocalModelTest exposing (all)

import Expect
import Gen.Processes as Gen
import Fuzz exposing (int, tuple)
import Maybe exposing (andThen)
import Test exposing (Test, describe)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Utils exposing (swap, andJust)
import Game.Servers.Processes.Types.Shared exposing (..)
import Game.Servers.Processes.Types.Local exposing (ProcessState(..))
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


getState : Process -> Maybe ProcessState
getState process =
    case process.prop of
        LocalProcess prop ->
            Just prop.state

        _ ->
            Nothing


getStateForJust : Process -> ProcessState
getStateForJust process =
    Maybe.withDefault StateStandby (getState process)



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
        (tuple ( Gen.emptyProcesses, Gen.localProcess ))
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
    -- FIXME: TEST ONLY LOCAL PROCESSES
    [ fuzz
        (tuple ( Gen.localProcesses, Gen.localProcess ))
        "can pause a process"
      <|
        \( model, process ) ->
            model
                |> addProcess process
                |> (flip pauseProcess) process
                |> getProcessByID process.id
                |> andThen getState
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
    -- FIXME: TEST ONLY LOCAL PROCESSES
    [ fuzz
        (tuple ( Gen.localProcesses, Gen.localProcess ))
        "can resume a paused process"
      <|
        \( processes, process ) ->
            let
                model =
                    processes
                        |> addProcess process
                        |> (flip pauseProcess) process

                maybeState =
                    model
                        |> getProcessByID process.id
                        |> andJust (resumeProcess model)
                        |> andThen (getProcessByID process.id)
                        |> andJust getStateForJust
            in
                Expect.equal (Just StateRunning) maybeState
    , fuzz
        (tuple ( Gen.localProcesses, Gen.localProcess ))
        "can't resume a running process"
      <|
        \( processes, process ) ->
            let
                model =
                    processes
                        |> addProcess process
                        |> (flip resumeProcess) process
            in
                model
                    |> getProcessByID process.id
                    |> andJust (resumeProcess model)
                    |> andThen (getProcessByID process.id)
                    |> andJust getStateForJust
                    |> Expect.equal (Just StateRunning)
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
    -- FIXME: TEST ONLY LOCAL PROCESSES
    [ fuzz
        (tuple ( Gen.localProcesses, Gen.localProcess ))
        "can complete a process"
      <|
        \( processes, process ) ->
            let
                model =
                    processes
                        |> addProcess process
                        |> (flip completeProcess) process
            in
                model
                    |> getProcessByID (getProcessID process)
                    |> andJust getStateForJust
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
        (tuple ( Gen.localProcesses, Gen.localProcess ))
        "can delete a process"
      <|
        \( processes, process ) ->
            processes
                |> addProcess process
                |> (flip removeProcess) process
                |> getProcessByID process.id
                |> Expect.equal Nothing
    , fuzz
        (tuple ( Gen.localProcesses, Gen.localProcess ))
        "can't delete a non-existing process"
      <|
        \( processes, process ) ->
            processes
                |> (flip removeProcess) process
                |> Expect.equal processes
    ]
