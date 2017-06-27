module Game.Servers.Update exposing (..)

import Dict
import Utils.Dict as DictUtils
import Game.Messages as Game
import Game.Models as Game
import Core.Dispatch as Dispatch exposing (Dispatch)
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
    Game.Model
    -> Msg
    -> Model
    -> ( Model, Cmd Game.Msg, Dispatch )
update game msg model =
    case msg of
        FilesystemMsg id msg ->
            filesystem game id msg model

        LogMsg id msg ->
            log game id msg model

        ProcessMsg id msg ->
            process game id msg model

        Request data ->
            response game (receive data) model

        _ ->
            ( model, Cmd.none, Dispatch.none )



-- internals


response :
    Game.Model
    -> Response
    -> Model
    -> ( Model, Cmd Game.Msg, Dispatch )
response response game model =
    case response of
        _ ->
            ( model, Cmd.none, Dispatch.none )


filesystem :
    Game.Model
    -> ID
    -> Filesystem.Msg
    -> Model
    -> ( Model, Cmd Game.Msg, Dispatch )
filesystem game id msg model =
    case Dict.get id model of
        Just server ->
            let
                ( filesystem_, cmd, dispatch ) =
                    Filesystem.update game msg (getFilesystem server)

                server_ =
                    setFilesystem filesystem_ server

                model_ =
                    DictUtils.safeUpdate id server_ model
            in
                ( model_, cmd, dispatch )

        Nothing ->
            ( model, Cmd.none, Dispatch.none )


log :
    Game.Model
    -> ID
    -> Logs.Msg
    -> Model
    -> ( Model, Cmd Game.Msg, Dispatch )
log game id msg model =
    case (Dict.get id model) of
        Just server ->
            let
                ( logs_, cmd, dispatch ) =
                    Logs.update game msg (getLogs server)

                server_ =
                    setLogs logs_ server

                model_ =
                    DictUtils.safeUpdate id server_ model
            in
                ( model_, cmd, dispatch )

        Nothing ->
            ( model, Cmd.none, Dispatch.none )


process :
    Game.Model
    -> ID
    -> Processes.Msg
    -> Model
    -> ( Model, Cmd Game.Msg, Dispatch )
process game id msg model =
    case (Dict.get id model) of
        Just server ->
            let
                ( processes_, cmd, dispatch ) =
                    Processes.update game msg (getProcesses server)

                server_ =
                    setProcesses processes_ server

                model_ =
                    DictUtils.safeUpdate id server_ model
            in
                ( model_, cmd, dispatch )

        Nothing ->
            ( model, Cmd.none, Dispatch.none )
