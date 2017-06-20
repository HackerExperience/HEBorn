module Game.Servers.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Game.Messages exposing (GameMsg(..))
import Game.Models exposing (GameModel)
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Filesystem.Update as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Logs.Update as Logs
import Game.Servers.Messages exposing (..)
import Game.Servers.Models exposing (..)
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Processes.Update as Processes
import Game.Servers.Requests exposing (..)


update : Msg -> Servers -> GameModel -> ( Servers, Cmd GameMsg, List CoreMsg )
update msg model game =
    case msg of
        MsgFilesystem id msg ->
            filesystem id msg model game

        MsgLog id msg ->
            log id msg model game

        MsgProcess id msg ->
            process id msg model game

        Request data ->
            response (receive data) model game

        _ ->
            ( model, Cmd.none, [] )



-- internals


response :
    Response
    -> Servers
    -> GameModel
    -> ( Servers, Cmd GameMsg, List CoreMsg )
response response model game =
    case response of
        _ ->
            ( model, Cmd.none, [] )


filesystem :
    ServerID
    -> Filesystem.Msg
    -> Servers
    -> GameModel
    -> ( Servers, Cmd GameMsg, List CoreMsg )
filesystem id msg model game =
    case (getServerByID model id) of
        StdServer server ->
            let
                ( filesystem_, cmd, msgs ) =
                    Filesystem.update msg server.filesystem game

                server_ =
                    StdServer { server | filesystem = filesystem_ }

                model_ =
                    updateServer model server_
            in
                ( model_, cmd, msgs )

        NoServer ->
            ( model, Cmd.none, [] )


log :
    ServerID
    -> Logs.Msg
    -> Servers
    -> GameModel
    -> ( Servers, Cmd GameMsg, List CoreMsg )
log id msg model game =
    case (getServerByID model id) of
        StdServer server ->
            let
                ( logs_, cmd, msgs ) =
                    Logs.update msg server.logs game

                server_ =
                    StdServer { server | logs = logs_ }

                model_ =
                    updateServer model server_
            in
                ( model_, cmd, msgs )

        NoServer ->
            ( model, Cmd.none, [] )


process :
    ServerID
    -> Processes.Msg
    -> Servers
    -> GameModel
    -> ( Servers, Cmd GameMsg, List CoreMsg )
process id msg model game =
    case (getServerByID model id) of
        StdServer server ->
            let
                ( processes_, cmd, msgs ) =
                    Processes.update msg server.processes game

                server_ =
                    StdServer { server | processes = processes_ }

                model_ =
                    updateServer model server_
            in
                ( model_, cmd, msgs )

        NoServer ->
            ( model, Cmd.none, [] )
