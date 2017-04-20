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
import Game.Servers.Filesystem.Models exposing (File, addFile)
import Gen.Game
import Gen.Servers
import Gen.Filesystem
import Helper.Filesystem exposing (addFileRecursively)


one : Int -> Int -> ( GameModel, Server, ( File, File ) )
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
            addFile (getFilesystem server) file

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
    in
        ( game, server, ( file, folder ) )
