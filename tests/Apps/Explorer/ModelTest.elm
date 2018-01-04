module Apps.Explorer.ModelTest exposing (all, pathOperations)

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

                maybeFilesystem =
                    server
                        |> Servers.getMainStorage
                        |> Maybe.map Servers.getFilesystem
                        |> Maybe.map (mkdirp folder_)

                explorer =
                    case maybeFilesystem of
                        Just fs ->
                            changePath folder_ fs initialModel

                        Nothing ->
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
                        |> Maybe.map Tuple.second
                        |> Maybe.andThen Servers.getMainStorage
                        |> Maybe.map Servers.getFilesystem
            in
                case maybeServer of
                    Just fs ->
                        initialModel
                            |> changePath folder_ fs
                            |> Expect.equal initialModel

                    Nothing ->
                        -- FIXME: game state should provide Game.Data
                        Expect.equal initialModel initialModel
    ]
