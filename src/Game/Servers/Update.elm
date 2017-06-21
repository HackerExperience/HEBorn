module Game.Servers.Update exposing (..)

import Core.Messages as Core
import Game.Messages as Game
import Game.Models as Game
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Filesystem.Update as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Logs.Update as Logs
import Game.Servers.Messages exposing (..)
import Game.Servers.Models exposing (..)
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Processes.Update as Processes
import Game.Servers.Requests exposing (..)


update :
    Msg
    -> Model
    -> Game.Model
    -> ( Model, Cmd Game.Msg, List Core.Msg )
update msg model game =
    case msg of
        FilesystemMsg id msg ->
            filesystem id msg model game

        LogMsg id msg ->
            log id msg model game

        ProcessMsg id msg ->
            process id msg model game

        Request data ->
            response (receive data) model game

        _ ->
            ( model, Cmd.none, [] )



-- internals


response :
    Response
    -> Model
    -> Game.Model
    -> ( Model, Cmd Game.Msg, List Core.Msg )
response response model game =
    case response of
        _ ->
            ( model, Cmd.none, [] )


filesystem :
    ServerID
    -> Filesystem.Msg
    -> Model
    -> Game.Model
    -> ( Model, Cmd Game.Msg, List Core.Msg )
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
    -> Model
    -> Game.Model
    -> ( Model, Cmd Game.Msg, List Core.Msg )
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
    -> Model
    -> Game.Model
    -> ( Model, Cmd Game.Msg, List Core.Msg )
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
