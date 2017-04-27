module Helper.Playstate exposing (..)

import Game.Models exposing (GameModel)
import Game.Servers.Models exposing (..)
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
            addFileRecursively file (getFilesystemSafe server)

        filesystem_ =
            addFileRecursively folder filesystem1

        server_ =
            updateFilesystem server filesystem_

        servers =
            addServer game0.servers (getServerSafe server_)

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
