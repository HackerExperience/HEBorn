module Game.Servers.Logs.ModelTest exposing (all)

import Expect
import Gen.Logs as Gen
import Test exposing (Test, describe)
import Fuzz exposing (tuple, tuple3)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Game.Servers.Logs.Models exposing (..)


-- TODO: refactor


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
        (tuple ( Gen.model, Gen.tuple ))
        "can add a LogEntry but not a NoLog"
      <|
        \( model, ( id, log ) ) ->
            insert id log model
                |> member id
                |> Expect.equal True
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
        (tuple3 ( Gen.model, Gen.tuple, Gen.data ))
        "update Log contents"
      <|
        \( model, ( id, log ), data ) ->
            let
                content =
                    getContent <|
                        new
                            (getTimestamp log)
                            log.status
                            (Just data.raw)
            in
                insert id log model
                    |> insert id (setContent (Just data.raw) log)
                    |> get id
                    |> Maybe.map getContent
                    |> Expect.equal (Just content)
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
        (tuple ( Gen.model, Gen.tuple ))
        "log no longer exists"
      <|
        \( model, ( id, log ) ) ->
            insert id log model
                |> remove id
                |> member id
                |> Expect.equal False
    , fuzz
        (tuple ( Gen.model, Gen.id ))
        "can't delete a non-existing log"
      <|
        \( model, id ) ->
            Expect.equal model <| remove id model
    ]
