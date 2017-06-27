module Apps.Explorer.ModelTest exposing (all)

import Dict
import Expect
import Gen.Filesystem
import Helper.Playstate as Playstate
import Helper.Filesystem as Helper exposing (addFileRecursively)
import Fuzz exposing (tuple)
import Test exposing (Test, describe)
import TestUtils exposing (fuzz, once)
import Apps.Explorer.Models as Explorer exposing (..)
import Game.Servers.Filesystem.Models as Filesystem exposing (..)


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
    [ once
        Playstate.one
        "can move to an existing folder"
      <|
        \{ game, server, valid } ->
            let
                { folder } =
                    valid

                newServerWithFile =
                    { server
                        | filesystem =
                            addFileRecursively folder server.filesystem
                    }

                explorer =
                    changePath (getAbsolutePath folder)
                        newServerWithFile.filesystem
                        initialExplorer
            in
                folder
                    |> getAbsolutePath
                    |> Expect.equal (getPath explorer)
    , fuzz
        (tuple ( Playstate.one, Gen.Filesystem.path ))
        "can't move to a non-existing folder"
      <|
        \( { game }, path ) ->
            case Dict.get "localhost" game.servers of
                Just server ->
                    initialExplorer
                        |> changePath path server.filesystem
                        |> Expect.equal initialExplorer

                Nothing ->
                    -- FIXME: game state should provide Game.Data
                    Expect.equal initialExplorer initialExplorer
    ]
