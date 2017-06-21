module Helper.Playstate exposing (..)

import Gen.Filesystem
import Gen.Game
import Gen.Servers
import Fuzz exposing (Fuzzer)
import Game.Models as Game
import Game.Servers.Filesystem.Models exposing (File, addFile, getFileName)
import Helper.Filesystem exposing (addFileRecursively)
import Random.Pcg as Random exposing (Generator)
import Random.Pcg.Extra as RandomExtra exposing (andMap)
import Game.Servers.Models exposing (..)
import Gen.Utils exposing (..)


type alias ValidState =
    { file : File
    , folder : File
    }


type alias InvalidState =
    { file : File
    , folder : File
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
        generateStateRecord =
            \game server file1 file2 folder1 folder2 ->
                let
                    servers =
                        server
                            |> getFilesystemSafe
                            |> addFileRecursively file1
                            |> addFileRecursively folder1
                            |> updateFilesystem server
                            |> getServerSafe
                            |> addServer game.servers

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
                    , server = server
                    , valid = valid
                    , invalid = invalid
                    }
    in
        Gen.Game.genModel
            |> Random.map generateStateRecord
            |> andMap Gen.Servers.genServer
            |> andMap Gen.Filesystem.genStdFile
            |> andMap Gen.Filesystem.genStdFile
            |> andMap Gen.Filesystem.genFolder
            |> andMap Gen.Filesystem.genFolder
