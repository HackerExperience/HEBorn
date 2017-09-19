module Game.Servers.Processes.ModelTest exposing (all)

import Expect
import Gen.Processes as Gen
import Fuzz exposing (int, tuple)
import Test exposing (Test, describe)
import TestUtils exposing (fuzz, once, batch, ensureDifferentSeed)
import Utils.Core exposing (swap)
import Game.Servers.Processes.Models as Processes exposing (..)


all : Test
all =
    describe "process"
        [ processOperationsTests
        ]


processContractTests : Test
processContractTests =
    describe "process contract guards"
        [ describe "when incomplete"
            whenIncompleteTests
        , describe "when full access"
            whenFullAccessTests
        ]


processOperationsTests : Test
processOperationsTests =
    describe "process operations"
        [ describe "add process"
            addProcessTests
        , describe "state change"
            processStateChangeTests
        , describe "delete process"
            deleteProcessTests
        ]



--------------------------------------------------------------------------------
-- Process when incomplete constraint tests
--------------------------------------------------------------------------------


whenIncompleteTests : List Test
whenIncompleteTests =
    [ fuzz
        Gen.process
        "can perform action on incomplete processes"
      <|
        \process0 ->
            let
                process1 =
                    { process0 | state = Running }

                process2 =
                    whenIncomplete resume process1
            in
                Expect.notEqual process1 process2
    , fuzz
        Gen.process
        "can't perform action on complete processes"
      <|
        \process ->
            let
                processSucceeded =
                    { process | state = Succeeded }

                processSucceeded_ =
                    conclude (Just False) Nothing processSucceeded

                processFailed =
                    { process | state = Failed Nothing }

                processFailed_ =
                    conclude (Just True) Nothing processFailed
            in
                batch
                    [ Expect.equal processSucceeded processSucceeded_
                    , Expect.equal processFailed processFailed_
                    ]
    ]



--------------------------------------------------------------------------------
-- Process when full access constraint tests
--------------------------------------------------------------------------------


whenFullAccessTests : List Test
whenFullAccessTests =
    [ fuzz
        Gen.fullProcess
        "can perform action on full processes"
      <|
        \process0 ->
            let
                process1 =
                    { process0 | state = Paused }

                process2 =
                    whenFullAccess resume process1
            in
                Expect.notEqual process1 process2
    , fuzz
        Gen.partialProcess
        "can perform action on full processes"
      <|
        \process0 ->
            let
                process1 =
                    { process0 | state = Paused }

                process2 =
                    whenFullAccess resume process1
            in
                Expect.equal process1 process2
    ]



--------------------------------------------------------------------------------
-- Add Process
--------------------------------------------------------------------------------


addProcessTests : List Test
addProcessTests =
    [ describe "generic add full or partial process test"
        addProcessGenericTests
    ]


addProcessGenericTests : List Test
addProcessGenericTests =
    [ fuzz
        (tuple ( Gen.model, tuple ( Gen.id, Gen.process ) ))
        "can add a process"
      <|
        \( model, ( id, process ) ) ->
            model
                |> Processes.insert id process
                |> Processes.get id
                |> Expect.equal (Just process)
    ]



--------------------------------------------------------------------------------
-- Change Process State
--------------------------------------------------------------------------------


processStateChangeTests : List Test
processStateChangeTests =
    [ fuzz
        Gen.process
        "resume a process"
      <|
        resume
            >> getState
            >> Expect.equal Running
    , fuzz
        Gen.process
        "pause a process"
      <|
        pause
            >> getState
            >> Expect.equal Paused
    , fuzz
        Gen.process
        "conclude a process with no conclusion status"
      <|
        conclude Nothing Nothing
            >> getState
            >> Expect.equal Concluded
    , fuzz
        Gen.process
        "conclude a process with failure"
      <|
        conclude (Just False) (Just "failed")
            >> getState
            >> Expect.equal (Failed <| Just "failed")
    , fuzz
        Gen.process
        "conclude a process with success"
      <|
        conclude (Just True) Nothing
            >> getState
            >> Expect.equal Succeeded
    ]



-- --------------------------------------------------------------------------------
-- -- Delete Process
-- --------------------------------------------------------------------------------


deleteProcessTests : List Test
deleteProcessTests =
    [ describe "impossible to delete completed or partial process test"
        deleteProcessGenericTests
    ]


deleteAssert : Process -> (Maybe Process -> Expect.Expectation)
deleteAssert process =
    case Processes.getState process of
        Processes.Starting ->
            Expect.equal (Just process)

        _ ->
            Expect.equal (Nothing)


deleteProcessGenericTests : List Test
deleteProcessGenericTests =
    [ fuzz
        (tuple ( Gen.model, tuple ( Gen.id, Gen.process ) ))
        "can delete allowed process"
      <|
        \( model, ( id, process ) ) ->
            model
                |> Processes.insert id process
                |> Processes.remove id
                |> Processes.get id
                |> deleteAssert process
    , fuzz
        (tuple ( Gen.model, Gen.id ))
        "can't delete a non-existing process"
      <|
        \( model, id ) ->
            model
                |> Processes.remove id
                |> Expect.equal model
    ]
