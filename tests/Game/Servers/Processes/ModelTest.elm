module Game.Servers.Processes.ModelTest exposing (all)

import Expect
import Gen.Processes as Gen
import Fuzz exposing (int, tuple)
import Test exposing (Test, describe)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Utils.Core exposing (swap)
import Game.Servers.Processes.Models as Processes exposing (Process)


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
-- Pause Process
--------------------------------------------------------------------------------


pauseProcessTests : List Test
pauseProcessTests =
    [ describe "impossible to pause completed or partial process test"
        invalidPauseProcessTests
    ]


invalidPauseProcessTests : List Test
invalidPauseProcessTests =
    stateChangeHelper
        "can pause allowed process"
        Processes.Paused
        Processes.pause



-- --------------------------------------------------------------------------------
-- -- Resume Process
-- --------------------------------------------------------------------------------


resumeProcessTests : List Test
resumeProcessTests =
    [ describe "impossible to resume completed or partial process test"
        invalidResumeProcessTests
    ]


invalidResumeProcessTests : List Test
invalidResumeProcessTests =
    stateChangeHelper
        "can resume allowed process"
        Processes.Running
        Processes.resume



--------------------------------------------------------------------------------
-- State Changing Helper
--------------------------------------------------------------------------------


assertStateChange : Processes.State -> Process -> (Process -> Expect.Expectation)
assertStateChange expected process =
    case Processes.getAccess process of
        Processes.Full _ ->
            if Processes.isConcluded process then
                Expect.equal process
            else
                (Processes.getState >> Expect.equal expected)

        Processes.Partial _ ->
            Expect.equal process


stateChangeHelper : String -> Processes.State -> (Process -> Process) -> List Test
stateChangeHelper label expected handler =
    [ fuzz
        Gen.process
        label
        (\process -> process |> handler |> assertStateChange expected process)
    ]



--------------------------------------------------------------------------------
-- Complete Process
--------------------------------------------------------------------------------


completeProcessTests : List Test
completeProcessTests =
    [ describe "impossible to complete partial process test"
        invalidCompleteProcessTests
    ]


invalidCompleteProcessTests : List Test
invalidCompleteProcessTests =
    let
        assert process =
            case Processes.getAccess process of
                Processes.Full _ ->
                    if Processes.isConcluded process then
                        Expect.equal process
                    else
                        (Processes.getState >> Expect.equal Processes.Succeeded)

                Processes.Partial _ ->
                    Expect.equal process
    in
        [ fuzz
            Gen.process
            "can complete allowed process"
            (\process ->
                Processes.conclude True (Just "") process
                    |> assert process
            )
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
