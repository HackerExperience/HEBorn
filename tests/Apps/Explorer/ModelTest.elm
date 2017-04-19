module Apps.Explorer.ModelTest exposing (all)

import Expect
import Test exposing (Test, describe)
import Fuzz exposing (int, tuple)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Gen.Game
import Gen.Software
import Gen.Explorer as Gen
import Game.Software.Models as Software exposing (..)
import Apps.Explorer.Models as Explorer exposing (..)


all : Test
all =
    describe "explorer"
        [ pathOperations
        ]


pathOperations : Test
pathOperations =
    describe "path operations"
        [ describe "move around"
            pathMoveAroundTests
        ]



--------------------------------------------------------------------------------
-- Move around
--------------------------------------------------------------------------------


pathMoveAroundTests : List Test
pathMoveAroundTests =
    [ fuzz (tuple ( int, int )) "can move to an existing folder" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                explorer =
                    initialExplorer

                game =
                    Gen.Game.model seed1

                -- TODO: ensureDiferenteSeed3
                folder =
                    Gen.Software.folder (seed2 + 1)

                software_ =
                    addFile game.software folder

                game_ =
                    { game | software = software_ }

                explorer_ =
                    changePath explorer game_ (getFilePath folder)
            in
                Expect.equal (getPath explorer_) (getFilePath folder)
    , fuzz (tuple ( int, int )) "cant move to a non-existing folder" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                explorer =
                    initialExplorer

                game =
                    Gen.Game.model seed1

                explorer_ =
                    changePath explorer game (Gen.Software.path seed2)
            in
                Expect.equal explorer explorer_
    ]
