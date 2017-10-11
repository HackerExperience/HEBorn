module Game.Servers.Update exposing (..)

import Dict
import Utils.Update as Update
import Utils.Maybe as Maybe
import Json.Decode as Decode exposing (Value)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events
import Events.Servers as ServersEvents
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
import Game.Network.Types exposing (NIP)
import Game.Servers.Requests.Resync as Resync


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias ServerUpdateResponse =
    ( Server, Cmd ServerMsg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        ServerMsg id msg ->
            onServerMsg game id msg model

        Resync id ->
            onResync game id model

        Event event ->
            onEvent game event model

        Request data ->
            onRequest game (receive data) model


onServerMsg : Game.Model -> ID -> ServerMsg -> Model -> UpdateResponse
onServerMsg game id msg model =
    case get id model of
        Just server ->
            server
                |> updateServer game model id msg
                |> Update.mapModel (flip (insert id) model)
                |> Update.mapCmd (ServerMsg id)

        Nothing ->
            Update.fromModel model


onEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
onEvent game event model =
    let
        msg =
            ServerEvent event

        reducer key server ( servers, cmd, dispatch ) =
            let
                serverId =
                    unsafeFromKey key servers

                ( server_, newCmd, newDispatch ) =
                    updateServer game model serverId msg server

                servers_ =
                    insert serverId server_ servers

                cmd_ =
                    Cmd.batch
                        [ Cmd.map (ServerMsg serverId) newCmd
                        , cmd
                        ]

                dispatch_ =
                    Dispatch.batch [ newDispatch, dispatch ]
            in
                ( servers_, cmd_, dispatch_ )
    in
        model.servers
            |> Dict.foldl reducer ( model, Cmd.none, Dispatch.none )
            |> Update.andThen (updateEvent game event)


onRequest : Game.Model -> Maybe Response -> Model -> UpdateResponse
onRequest game response model =
    case response of
        Just response ->
            updateRequest game response model

        Nothing ->
            Update.fromModel model


updateEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
updateEvent game event model =
    case event of
        Events.Report (Ws.Joined (ServerChannel id) value) ->
            onWsJoinedServer game id value model

        _ ->
            Update.fromModel model


updateRequest : Game.Model -> Response -> Model -> UpdateResponse
updateRequest game data model =
    case data of
        ResyncServer (Resync.Okay ( id, server )) ->
            Update.fromModel <| insert id server model


onWsJoinedServer : Game.Model -> ID -> Value -> Model -> UpdateResponse
onWsJoinedServer game id value model =
    let
        decodeBootstrap =
            Decoders.Servers.server <| getGateway id model
    in
        case Decode.decodeValue decodeBootstrap value of
            Ok server ->
                let
                    nip =
                        toNip id

                    accountMsg =
                        if isGateway server then
                            Account.InsertGateway nip
                        else
                            Account.InsertEndpoint nip

                    dispatch =
                        Dispatch.account accountMsg

                    model_ =
                        insert id server model
                in
                    ( model_, Cmd.none, dispatch )

            Err reason ->
                let
                    log =
                        Debug.log ("▶ Server Bootstrap Error:\n" ++ reason) ""
                in
                    Update.fromModel model


onResync : Game.Model -> ID -> Model -> UpdateResponse
onResync game id model =
    let
        cmd =
            Resync.request (getGateway id model) id game
    in
        ( model, cmd, Dispatch.none )


updateServer :
    Game.Model
    -> Model
    -> ID
    -> ServerMsg
    -> Server
    -> ServerUpdateResponse
updateServer game model id msg server =
    case msg of
        SetBounce maybeId ->
            onSetBounce game
                id
                maybeId
                server

        SetEndpoint maybeNip ->
            onSetEndpoint game maybeNip server

        FilesystemMsg msg ->
            onFilesystemMsg game id msg server

        LogsMsg msg ->
            onLogsMsg game id msg server

        ProcessesMsg msg ->
            onProcessesMsg game id msg server

        TunnelsMsg msg ->
            onTunnelsMsg game msg server

        ServerEvent event ->
            onServerEvent game id event server

        ServerRequest data ->
            updateServerRequest game (serverReceive data) server

        NotificationsMsg msg ->
            onNotificationsMsg game msg server


onSetBounce :
    Game.Model
    -> NIP
    -> Maybe Bounces.ID
    -> Server
    -> ServerUpdateResponse
onSetBounce game nip maybeId server =
    setBounce maybeId server
        |> Update.fromModel


onSetEndpoint :
    Game.Model
    -> Maybe NIP
    -> Server
    -> ServerUpdateResponse
onSetEndpoint game nip server =
    setEndpoint nip server
        |> Update.fromModel


onFilesystemMsg :
    Game.Model
    -> NIP
    -> Filesystem.Msg
    -> Server
    -> ServerUpdateResponse
onFilesystemMsg game nip =
    Update.child
        { get = .filesystem
        , set = (\fs model -> { model | filesystem = fs })
        , toMsg = FilesystemMsg
        , update = (Filesystem.update game nip)
        }


onLogsMsg :
    Game.Model
    -> NIP
    -> Logs.Msg
    -> Server
    -> ServerUpdateResponse
onLogsMsg game nip =
    Update.child
        { get = .logs
        , set = (\logs model -> { model | logs = logs })
        , toMsg = LogsMsg
        , update = (Logs.update game nip)
        }


onProcessesMsg :
    Game.Model
    -> NIP
    -> Processes.Msg
    -> Server
    -> ServerUpdateResponse
onProcessesMsg game nip =
    Update.child
        { get = .processes
        , set = (\processes model -> { model | processes = processes })
        , toMsg = ProcessesMsg
        , update = (Processes.update game nip)
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


onServerEvent :
    Game.Model
    -> NIP
    -> Events.Event
    -> Server
    -> ServerUpdateResponse
onServerEvent game nip event server =
    if shouldRouteEvent nip event then
        onLogsMsg game nip (Logs.Event event) server
            -- |> Update.andThen (onFilesystemMsg game (Filesystem.Event event))
            |> Update.andThen (onProcessesMsg game nip (Processes.Event event))
            |> Update.andThen (onTunnelsMsg game (Tunnels.Event event))
            |> Update.andThen (updateServerEvent game event)
    else
        Update.fromModel server


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


updateServerEvent :
    Game.Model
    -> Events.Event
    -> Server
    -> ServerUpdateResponse
updateServerEvent game event server =
    Update.fromModel server


{-| Only route server events when server IDs match.
-}
shouldRouteEvent : NIP -> Events.Event -> Bool
shouldRouteEvent nip event =
    case event of
        Events.ServersEvent (ServerChannel nip_) _ ->
            nip == nip_

        _ ->
            True
