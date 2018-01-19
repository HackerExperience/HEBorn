module Helper.Playstate exposing (..)

import Gen.Filesystem
import Gen.Game
import Gen.Servers
import Fuzz exposing (Fuzzer)
import Game.Models as Game
import Game.Servers.Filesystem.Models exposing (..)
import Game.Servers.Filesystem.Shared exposing (..)
import Random.Pcg as Random exposing (Generator)
import Random.Pcg.Extra as RandomExtra exposing (andMap)
import Game.Servers.Models as Servers exposing (..)
import Gen.Utils exposing (..)


type alias ValidState =
    { file : FileEntry
    , folder : ( Path, Name )
    }


type alias InvalidState =
    { file : FileEntry
    , folder : ( Path, Name )
    }


type alias State =
    { game : Game.Model
    , server : Server
    , valid : ValidState
    , invalid : InvalidState
    }



--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


one : Fuzzer State
one =
    fuzzer genOne



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genOne : Generator State
genOne =
    let
        generateStateRecord game id server file1 file2 folder1 folder2 =
            let
                maybeStorage =
                    getMainStorage server

                maybeFilesystem =
                    maybeStorage
                        |> Maybe.map getFilesystem
                        |> Maybe.map (uncurry insertFile file1)
                        |> Maybe.map (uncurry insertFolder folder1)

                maybeStorage_ =
                    case ( maybeStorage, maybeFilesystem ) of
                        ( Just storage, Just fs ) ->
                            Just <| setFilesystem fs storage

                        _ ->
                            Nothing

                server_ =
                    case maybeStorage_ of
                        Just storage ->
                            setStorage (getMainStorageId server) storage server

                        Nothing ->
                            server

                servers =
                    Servers.insert id server_ game.servers

                game_ =
                    { game | servers = servers }

                valid =
                    ValidState
                        file1
                        folder1

                invalid =
                    InvalidState
                        file2
                        folder2
            in
                { game = game_
                , server = server_
                , valid = valid
                , invalid = invalid
                }
    in
        Gen.Game.genModel
            |> Random.map generateStateRecord
            |> andMap Gen.Servers.genServerCId
            |> andMap Gen.Servers.genServer
            |> andMap Gen.Filesystem.genFileEntry
            |> andMap Gen.Filesystem.genFileEntry
            |> andMap Gen.Filesystem.genFolder
            |> andMap Gen.Filesystem.genFolder
