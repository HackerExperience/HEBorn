module Apps.Explorer.ModelTest exposing (all)

import Expect
import Test exposing (Test, describe)
import Fuzz exposing (int, tuple)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Gen.Game
import Gen.Servers
import Gen.Filesystem
import Gen.Explorer as Gen
import Helper.Playstate as Playstate
import Game.Servers.Models as Server exposing (..)
import Game.Servers.Filesystem.Models as Filesystem exposing (..)
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
    [ once (tuple ( int, int )) "can move to an existing folder" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                explorer0 =
                    initialExplorer

                play =
                    Playstate.one seed1 seed2

                ( game, server, folder ) =
                    ( play.game, play.server, play.valid.folder )

                explorer =
                    { explorer0 | serverID = (getServerIDSafe server) }

                explorer_ =
                    changePath explorer game (getFilePath folder)
            in
                Expect.equal (getPath explorer_) (getFilePath folder)
    , fuzz (tuple ( int, int )) "cant move to a non-existing folder" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                explorer =
                    initialExplorer

                play =
                    Playstate.one seed1 seed2

                game =
                    play.game

                explorer_ =
                    changePath explorer game (Gen.Filesystem.path seed2)
            in
                Expect.equal explorer explorer_
    ]
