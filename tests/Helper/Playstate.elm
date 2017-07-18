module Helper.Playstate exposing (..)

import Gen.Filesystem
import Gen.Game
import Gen.Servers
import Fuzz exposing (Fuzzer)
import Game.Models as Game
import Game.Servers.Filesystem.Shared exposing (Entry)
import Game.Servers.Filesystem.Models exposing (addEntry)
import Helper.Filesystem exposing (createLocation)
import Random.Pcg as Random exposing (Generator)
import Random.Pcg.Extra as RandomExtra exposing (andMap)
import Game.Servers.Models as Servers exposing (..)
import Gen.Utils exposing (..)


type alias ValidState =
    { file : Entry
    , folder : Entry
    }


type alias InvalidState =
    { file : Entry
    , folder : Entry
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
                servers =
                    server
                        |> getFilesystem
                        |> addEntry file1
                        |> addEntry folder1
                        |> flip setFilesystem server
                        |> flip (Servers.insert id) game.servers

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
            |> andMap Gen.Servers.genServerID
            |> andMap Gen.Servers.genServer
            |> andMap Gen.Filesystem.genFile
            |> andMap Gen.Filesystem.genFile
            |> andMap Gen.Filesystem.genFolder
            |> andMap Gen.Filesystem.genFolder
