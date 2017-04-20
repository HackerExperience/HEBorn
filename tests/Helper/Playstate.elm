module Helper.Playstate exposing (..)

import Game.Models exposing (GameModel)
import Game.Servers.Models
    exposing
        ( Server
        , addServer
        , getServer
        , getFilesystem
        , updateServer
        , updateFilesystem
        )
import Game.Servers.Filesystem.Models exposing (File, addFile, getFileName)
import Gen.Game
import Gen.Servers
import Gen.Filesystem
import Helper.Filesystem exposing (addFileRecursively)


type alias ValidState =
    { file : File
    , folder : File
    }


type alias InvalidState =
    { file : File
    , folder : File
    }


type alias State =
    { game : GameModel
    , server : Server
    , valid : ValidState
    , invalid : InvalidState
    }


one : Int -> Int -> State
one seed1 seed2 =
    let
        game0 =
            Gen.Game.model seed1

        server =
            Gen.Servers.server seed2

        file =
            Gen.Filesystem.stdFile (seed1 + 1)

        folder =
            Gen.Filesystem.folder (seed2 + 1)

        filesystem1 =
            addFileRecursively (getFilesystem server) file

        filesystem_ =
            addFileRecursively filesystem1 folder

        server_ =
            updateFilesystem server filesystem_

        servers =
            addServer game0.servers (getServer server_)

        game =
            { game0
                | servers = servers
            }

        unboudedFile =
            Gen.Filesystem.stdFile (seed1 + 2)

        unboudedFolder =
            Gen.Filesystem.folder (seed2 + 2)
    in
        let
            valid =
                ValidState
                    file
                    folder

            invalid =
                InvalidState
                    unboudedFile
                    unboudedFolder
        in
            { game = game
            , server = server
            , valid = valid
            , invalid = invalid
            }
