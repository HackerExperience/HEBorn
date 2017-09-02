module Game.Servers.Processes.LocalModelTest exposing (all)

import Expect
import Gen.Processes as Gen
import Fuzz exposing (int, tuple)
import Test exposing (Test, describe)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Utils.Core exposing (swap)
import Game.Servers.Processes.Types.Shared exposing (..)
import Game.Servers.Processes.Types.Local exposing (ProcessState(..))
import Game.Servers.Processes.Models exposing (..)


type alias Process =
    ( ProcessID, ProcessProp )


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


getState : ProcessProp -> Maybe ProcessState
getState prop =
    case prop of
        LocalProcess prop ->
            Just prop.state

        _ ->
            Nothing


getStateForJust : ProcessProp -> ProcessState
getStateForJust prop =
    Maybe.withDefault StateStandby (getState prop)



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
        \( processes, ( id, prop ) ) ->
            processes
                |> addProcess id prop
                |> getProcess id
                |> Expect.equal (Just prop)
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
                |> uncurry addProcess process
                |> pauseProcess (Tuple.first process)
                |> getProcess (Tuple.first process)
                |> Maybe.andThen getState
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
        \( processes, ( id, prop ) ) ->
            let
                model =
                    processes
                        |> addProcess id prop
                        |> pauseProcess id

                maybeState =
                    model
                        |> resumeProcess id
                        |> getProcess id
                        |> Maybe.map getStateForJust
            in
                Expect.equal (Just StateRunning) maybeState
    , fuzz
        (tuple ( Gen.localProcesses, Gen.localProcess ))
        "can't resume a running process"
      <|
        \( processes, ( id, prop ) ) ->
            let
                model =
                    processes
                        |> addProcess id prop
                        |> resumeProcess id
            in
                model
                    |> resumeProcess id
                    |> getProcess id
                    |> Maybe.map getStateForJust
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
                        |> uncurry addProcess process
                        |> completeProcess (Tuple.first process)
                        |> Tuple.first
            in
                model
                    |> getProcess (Tuple.first process)
                    |> Maybe.map getStateForJust
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
                |> uncurry addProcess process
                |> removeProcess (Tuple.first process)
                |> getProcess (Tuple.first process)
                |> Expect.equal Nothing
    , fuzz
        (tuple ( Gen.localProcesses, Gen.localProcess ))
        "can't delete a non-existing process"
      <|
        \( processes, process ) ->
            processes
                |> removeProcess (Tuple.first process)
                |> Expect.equal processes
    ]
