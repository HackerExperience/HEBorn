module Game.Servers.Update exposing (..)

import Dict
import Utils.Update as Update
import Utils.Maybe as Maybe
import Json.Decode as Decode exposing (Value)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Driver.Websocket.Channels exposing (Channel(ServerChannel))
import Driver.Websocket.Reports as Ws
import Game.Models as Game
import Game.Account.Messages as Account
import Game.Account.Bounces.Models as Bounces
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Filesystem.Update as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Logs.Update as Logs
import Game.Servers.Messages exposing (..)
import Game.Servers.Models exposing (..)
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Processes.Update as Processes
import Game.Servers.Requests exposing (..)
import Game.Servers.Shared exposing (..)
import Game.Servers.Tunnels.Messages as Tunnels
import Game.Servers.Tunnels.Update as Tunnels
import Decoders.Servers
import Game.Notifications.Messages as Notifications
import Game.Notifications.Update as Notifications
import Game.Servers.Requests.Resync as Resync


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias ServerUpdateResponse =
    ( Server, Cmd ServerMsg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        ServerMsg cid msg ->
            onServerMsg game cid msg model

        Resync cid ->
            onResync game cid model

        Request data ->
            onRequest game (receive data) model

        HandleJoinedServer cid value ->
            handleJoinedServer cid value model


onServerMsg : Game.Model -> CId -> ServerMsg -> Model -> UpdateResponse
onServerMsg game cid msg model =
    case get cid model of
        Just server ->
            server
                |> updateServer game model cid msg
                |> Update.mapModel (flip (insert cid) model)
                |> Update.mapCmd (ServerMsg cid)

        Nothing ->
            Update.fromModel model


onRequest : Game.Model -> Maybe Response -> Model -> UpdateResponse
onRequest game response model =
    case response of
        Just response ->
            updateRequest game response model

        Nothing ->
            Update.fromModel model


updateRequest : Game.Model -> Response -> Model -> UpdateResponse
updateRequest game data model =
    case data of
        ResyncServer (Resync.Okay ( cid, server )) ->
            Update.fromModel <| insert cid server model


onResync : Game.Model -> CId -> Model -> UpdateResponse
onResync game cid model =
    let
        cmd =
            Resync.request (getGateway cid model) cid game
    in
        ( model, cmd, Dispatch.none )


updateServer :
    Game.Model
    -> Model
    -> CId
    -> ServerMsg
    -> Server
    -> ServerUpdateResponse
updateServer game model cid msg server =
    case msg of
        SetBounce maybeBounceId ->
            onSetBounce game
                cid
                maybeBounceId
                server

        SetEndpoint maybeCId ->
            onSetEndpoint game maybeCId server

        FilesystemMsg msg ->
            onFilesystemMsg game cid msg server

        LogsMsg msg ->
            onLogsMsg game cid msg server

        ProcessesMsg msg ->
            onProcessesMsg game cid msg server

        TunnelsMsg msg ->
            onTunnelsMsg game msg server

        ServerRequest data ->
            updateServerRequest game (serverReceive data) server

        NotificationsMsg msg ->
            onNotificationsMsg game msg server


onSetBounce :
    Game.Model
    -> CId
    -> Maybe Bounces.ID
    -> Server
    -> ServerUpdateResponse
onSetBounce game cid maybeBounceId server =
    setBounce maybeBounceId server
        |> Update.fromModel


onSetEndpoint :
    Game.Model
    -> Maybe CId
    -> Server
    -> ServerUpdateResponse
onSetEndpoint game cid server =
    setEndpointCId cid server
        |> Update.fromModel


onFilesystemMsg :
    Game.Model
    -> CId
    -> Filesystem.Msg
    -> Server
    -> ServerUpdateResponse
onFilesystemMsg game cid =
    Update.child
        { get = .filesystem
        , set = (\fs model -> { model | filesystem = fs })
        , toMsg = FilesystemMsg
        , update = (Filesystem.update game cid)
        }


onLogsMsg :
    Game.Model
    -> CId
    -> Logs.Msg
    -> Server
    -> ServerUpdateResponse
onLogsMsg game cid =
    Update.child
        { get = .logs
        , set = (\logs model -> { model | logs = logs })
        , toMsg = LogsMsg
        , update = (Logs.update game cid)
        }


onProcessesMsg :
    Game.Model
    -> CId
    -> Processes.Msg
    -> Server
    -> ServerUpdateResponse
onProcessesMsg game cid =
    Update.child
        { get = .processes
        , set = (\processes model -> { model | processes = processes })
        , toMsg = ProcessesMsg
        , update = (Processes.update game cid)
        }


onTunnelsMsg : Game.Model -> Tunnels.Msg -> Server -> ServerUpdateResponse
onTunnelsMsg game =
    Update.child
        { get = .tunnels
        , set = (\tunnels model -> { model | tunnels = tunnels })
        , toMsg = TunnelsMsg
        , update = (Tunnels.update game)
        }


onNotificationsMsg :
    Game.Model
    -> Notifications.Msg
    -> Server
    -> ServerUpdateResponse
onNotificationsMsg game =
    Update.child
        { get = .notifications
        , set = (\notifications model -> { model | notifications = notifications })
        , toMsg = NotificationsMsg
        , update = (Notifications.update game)
        }


updateServerRequest :
    Game.Model
    -> Maybe ServerResponse
    -> Server
    -> ServerUpdateResponse
updateServerRequest game response server =
    case response of
        Just _ ->
            Update.fromModel server

        Nothing ->
            Update.fromModel server


handleJoinedServer : CId -> Value -> Model -> UpdateResponse
handleJoinedServer cid value model =
    let
        decodeBootstrap =
            Decoders.Servers.server <| getGateway cid model
    in
        case Decode.decodeValue decodeBootstrap value of
            Ok server ->
                let
                    dispatch =
                        if isGateway server then
                            cid
                                |> Account.InsertGateway
                                |> Dispatch.account
                        else
                            Dispatch.none

                    model_ =
                        insert cid server model
                in
                    ( model_, Cmd.none, dispatch )

            Err reason ->
                let
                    log =
                        Debug.log ("▶ Server Bootstrap Error:\n" ++ reason) ""
                in
                    Update.fromModel model
