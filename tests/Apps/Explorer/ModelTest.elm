module Apps.Explorer.ModelTest exposing (all)

import Expect
import Dict as Dict
import Gen.Filesystem
import Helper.Playstate as Playstate
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

                filesystem =
                    server
                        |> Servers.getFilesystem
                        |> addEntry folder

                newServerWithFile =
                    Servers.setFilesystem filesystem server

                ( destGrandpa, destParent ) =
                    getEntryLink folder filesystem

                destination =
                    destGrandpa ++ [ destParent ]

                explorer =
                    changePath destination
                        (Servers.getFilesystem newServerWithFile)
                        Explorer.initialModel
            in
                Expect.equal destination <| getPath explorer
    , fuzz
        (tuple ( Playstate.one, Gen.Filesystem.location ))
        "can't move to a non-existing folder"
      <|
        \( { game }, path ) ->
            let
                maybeServer =
                    game.servers.servers
                        |> Dict.toList
                        |> List.head
            in
                case maybeServer of
                    Just ( _, server ) ->
                        Explorer.initialModel
                            |> changePath path (Servers.getFilesystem server)
                            |> Expect.equal Explorer.initialModel

                    Nothing ->
                        -- FIXME: game state should provide Game.Data
                        Expect.equal Explorer.initialModel Explorer.initialModel
    ]
