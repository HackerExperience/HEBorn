module Game.Servers.Update exposing (..)

import Dict
import Utils.Update as Update
import Utils.Maybe as Maybe
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
import Game.Servers.Requests.Bootstrap as Bootstrap
import Game.Notifications.Messages as Notifications
import Game.Notifications.Update as Notifications
import Game.Network.Types exposing (NIP)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias ServerUpdateResponse =
    ( Server, Cmd ServerMsg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        ServerMsg id msg ->
            onServerMsg game id msg model

        Event event ->
            onEvent game event model

        Request data ->
            onRequest game (receive data) model


onServerMsg : Game.Model -> ID -> ServerMsg -> Model -> UpdateResponse
onServerMsg game id msg model =
    case get id model of
        Just server ->
            server
                |> updateServer game server.nip msg
                |> Update.mapModel (flip (insert id) model)
                |> Update.mapCmd (ServerMsg id)

        Nothing ->
            Update.fromModel model


onEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
onEvent game event model =
    let
        msg =
            ServerEvent event

        reducer id server ( servers, cmd, dispatch ) =
            Update.fromModel server
                |> Update.andThen (updateServer game server.nip msg)
                |> Update.mapModel (flip (Dict.insert id) servers)
                |> Update.mapCmd (ServerMsg id)
                |> Update.addCmd cmd
                |> Update.addDispatch dispatch
    in
        Dict.foldl reducer (Update.fromModel model.servers) model.servers
            |> Update.mapModel (\servers -> { model | servers = servers })
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
        Events.Report (Ws.Joined (ServerChannel nip) _) ->
            onWsJoinedServer game nip model

        _ ->
            Update.fromModel model


updateRequest : Game.Model -> Response -> Model -> UpdateResponse
updateRequest game data model =
    case data of
        BootstrapServer (Bootstrap.Okay ( id, server )) ->
            let
                model_ =
                    insert id server model

                dispatch =
                    if List.member server.nip game.account.gateways then
                        Dispatch.none
                    else
                        server.nip
                            |> Account.InsertEndpoint
                            |> Dispatch.account
            in
                ( model_, Cmd.none, dispatch )


onWsJoinedServer : Game.Model -> NIP -> Model -> UpdateResponse
onWsJoinedServer game nip model =
    case getByNIP nip model of
        Nothing ->
            let
                cmd =
                    Bootstrap.request nip game
            in
                ( model, cmd, Dispatch.none )

        _ ->
            --TODO: this will need to change once we adopt the new generic
            -- bootstrap onJoin method
            Update.fromModel model



-- content message handlers


updateServer : Game.Model -> NIP -> ServerMsg -> Server -> ServerUpdateResponse
updateServer game id msg server =
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
    let
        serverId =
            Maybe.andThen (flip mapNetwork <| Game.getServers game) nip
    in
        setEndpoint serverId server
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
