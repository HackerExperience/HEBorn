module Game.Servers.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Servers.Messages exposing (ServerMsg(..))
import Game.Servers.Models exposing (..)
import Game.Servers.Filesystem.Update as Filesystem
import Game.Servers.Logs.Update as Logs
import Game.Servers.Processes.Update as Processes


update : ServerMsg -> Servers -> GameModel -> ( Servers, Cmd GameMsg, List CoreMsg )
update msg model game =
    case msg of
        MsgFilesystem serverID subMsg ->
            case (getServerByID model serverID) of
                StdServer server ->
                    let
                        ( filesystem_, cmd, coreMsg ) =
                            Filesystem.update subMsg server.filesystem game

                        server_ =
                            StdServer { server | filesystem = filesystem_ }

                        model_ =
                            updateServer model server_
                    in
                        ( model_, cmd, coreMsg )

                NoServer ->
                    ( model, Cmd.none, [] )

        MsgLog serverID subMsg ->
            case (getServerByID model serverID) of
                StdServer server ->
                    let
                        ( logs_, cmd, coreMsg ) =
                            Logs.update subMsg server.logs game

                        server_ =
                            StdServer { server | logs = logs_ }

                        model_ =
                            updateServer model server_
                    in
                        ( model_, cmd, coreMsg )

                NoServer ->
                    ( model, Cmd.none, [] )

        MsgProcess serverID subMsg ->
            case (getServerByID model serverID) of
                StdServer server ->
                    let
                        ( processes_, cmd, coreMsg ) =
                            Processes.update subMsg server.processes game

                        server_ =
                            StdServer { server | processes = processes_ }

                        model_ =
                            updateServer model server_
                    in
                        ( model_, cmd, coreMsg )

                NoServer ->
                    ( model, Cmd.none, [] )
