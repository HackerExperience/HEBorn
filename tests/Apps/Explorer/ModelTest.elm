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
import Game.Servers.Models as Servers
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
                    server
                        |> Servers.getFilesystem
                        |> addFileRecursively folder
                        |> flip Servers.setFilesystem server

                explorer =
                    changePath (getAbsolutePath folder)
                        (Servers.getFilesystem newServerWithFile)
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
                        |> changePath path (Servers.getFilesystem server)
                        |> Expect.equal initialExplorer

                Nothing ->
                    -- FIXME: game state should provide Game.Data
                    Expect.equal initialExplorer initialExplorer
    ]
