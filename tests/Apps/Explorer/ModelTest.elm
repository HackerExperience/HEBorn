module Apps.Explorer.ModelTest exposing (all)

import Expect
import Gen.Filesystem
import Helper.Playstate as Playstate
import Helper.Filesystem as Helper exposing (addFileRecursively)
import Fuzz exposing (tuple)
import Test exposing (Test, describe)
import TestUtils exposing (fuzz, once)
import Utils exposing (swap, andThenWithDefault)
import Apps.Explorer.Models as Explorer exposing (..)
import Game.Servers.Filesystem.Models as Filesystem exposing (..)
import Game.Servers.Models as Server exposing (..)


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
                    case server of
                        StdServer server ->
                            StdServer
                                { server
                                    | filesystem =
                                        addFileRecursively folder server.filesystem
                                }

                        NoServer ->
                            NoServer

                explorer =
                    initialExplorer
                        |> (\app -> changePath (getAbsolutePath folder) app newServerWithFile)
            in
                folder
                    |> getAbsolutePath
                    |> Expect.equal (getPath explorer)
    , fuzz
        (tuple ( Playstate.one, Gen.Filesystem.path ))
        "can't move to a non-existing folder"
      <|
        \( { game }, path ) ->
            let
                server =
                    getServerByID game.servers "localhost"
            in
                initialExplorer
                    |> (\app -> changePath path app server)
                    |> Expect.equal initialExplorer
    ]
