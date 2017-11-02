module Apps.Explorer.ModelTest exposing (all)

import Expect
import Dict as Dict
import Gen.Filesystem
import Helper.Filesystem as Helper exposing (mkdirp)
import Helper.Playstate as Playstate
import Fuzz exposing (tuple)
import Test exposing (Test, describe)
import TestUtils exposing (fuzz, once)
import Apps.Explorer.Models exposing (..)
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Models as Filesystem


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

                ( path, name ) =
                    folder

                folder_ =
                    Filesystem.appendPath name path

                filesystem =
                    server
                        |> Servers.getFilesystem
                        |> mkdirp folder_

                newServerWithFile =
                    Servers.setFilesystem filesystem server

                explorer =
                    changePath folder_
                        (Servers.getFilesystem newServerWithFile)
                        initialModel
            in
                explorer
                    |> getPath
                    |> Expect.equal folder_
    , fuzz
        (tuple ( Playstate.one, Gen.Filesystem.folder ))
        "can't move to a non-existing folder"
      <|
        \( { game }, ( path, name ) ) ->
            let
                folder_ =
                    Filesystem.appendPath name path

                maybeServer =
                    game.servers.servers
                        |> Dict.toList
                        |> List.head
            in
                case maybeServer of
                    Just ( _, server ) ->
                        initialModel
                            |> changePath folder_
                                (Servers.getFilesystem server)
                            |> Expect.equal initialModel

                    Nothing ->
                        -- FIXME: game state should provide Game.Data
                        Expect.equal initialModel initialModel
    ]
