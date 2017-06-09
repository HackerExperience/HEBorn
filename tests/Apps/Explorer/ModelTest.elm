module Apps.Explorer.ModelTest exposing (all)

import Expect
import Gen.Filesystem
import Helper.Playstate as Playstate
import Fuzz exposing (tuple)
import Test exposing (Test, describe)
import TestUtils exposing (fuzz, once)
import Utils exposing (swap)
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

                explorer =
                    initialExplorer
                        |> (\app -> changePath (getFilePath folder) app game.servers)
            in
                folder
                    |> getFilePath
                    |> Expect.equal (getPath explorer)
    , fuzz
        (tuple ( Playstate.one, Gen.Filesystem.path ))
        "can't move to a non-existing folder"
      <|
        \( { game }, path ) ->
            initialExplorer
                |> (\app -> changePath path app game.servers)
                |> Expect.equal initialExplorer
    ]
