module Game.Servers.Update exposing (..)

import Utils.Update as Update
import Json.Decode as Decode exposing (Value)
import Decoders.Servers
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Account as Account
import Game.Account.Bounces.Models as Bounces
import Game.Meta.Models as Meta
import Game.Meta.Types.Network as Network
import Game.Notifications.Messages as Notifications
import Game.Notifications.Update as Notifications
import Game.Notifications.Source as Notifications
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Filesystem.Update as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Logs.Update as Logs
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Processes.Update as Processes
import Game.Servers.Hardware.Messages as Hardware
import Game.Servers.Hardware.Update as Hardware
import Game.Servers.Tunnels.Messages as Tunnels
import Game.Servers.Tunnels.Update as Tunnels
import Game.Servers.Requests.Resync as Resync
import Game.Servers.Config exposing (..)
import Game.Servers.Messages exposing (..)
import Game.Servers.Models exposing (..)
import Game.Servers.Requests exposing (..)
import Game.Servers.Shared exposing (..)


-- Remove me after refactor

import Game.Models as Game


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


type alias ServerUpdateResponse msg =
    ( Server, Cmd msg, Dispatch )



-- remember to remove Game.Model after refactoring


update : Config msg -> Game.Model -> Msg -> Model -> UpdateResponse msg
update config game msg model =
    case msg of
        ServerMsg cid msg ->
            onServerMsg config game cid msg model

        Resync cid ->
            onResync config cid model

        Request data ->
            onRequest config game data model

        HandleJoinedServer cid value ->
            handleJoinedServer config cid value model


onServerMsg :
    Config msg
    -> Game.Model
    -> CId
    -> ServerMsg
    -> Model
    -> UpdateResponse msg
onServerMsg config game cid msg model =
    case get cid model of
        Just server ->
            server
                |> updateServer config game cid model msg
                |> Update.mapModel (flip (insert cid) model)

        Nothing ->
            Update.fromModel model


onRequest :
    Config msg
    -> Game.Model
    -> RequestMsg
    -> Model
    -> UpdateResponse msg
onRequest config game data model =
    let
        lastTick =
            game
                |> Game.getMeta
                |> Meta.getLastTick

        response =
            receive lastTick data
    in
        case response of
            Just response ->
                updateRequest config response model

            Nothing ->
                Update.fromModel model


updateRequest : Config msg -> Response -> Model -> UpdateResponse msg
updateRequest config data model =
    case data of
        ResyncServer (Resync.Okay ( cid, server )) ->
            Update.fromModel <| insert cid server model


onResync : Config msg -> CId -> Model -> UpdateResponse msg
onResync config cid model =
    let
        cmd =
            config
                |> Resync.request (getGatewayCache cid model) cid
                |> Cmd.map config.toMsg
    in
        ( model, cmd, Dispatch.none )


updateServer :
    Config msg
    -> Game.Model
    -> CId
    -> Model
    -> ServerMsg
    -> Server
    -> ServerUpdateResponse msg
updateServer config game cid model msg server =
    case msg of
        HandleSetBounce maybeBounceId ->
            handleSetBounce config cid maybeBounceId server

        HandleSetEndpoint remote ->
            handleSetEndpoint config remote server

        HandleSetActiveNIP nip ->
            handleSetActiveNIP config nip server

        FilesystemMsg storageId msg ->
            onFilesystemMsg config game cid storageId msg server

        LogsMsg msg ->
            onLogsMsg config game cid msg server

        ProcessesMsg msg ->
            onProcessesMsg config cid msg server

        HardwareMsg msg ->
            onHardwareMsg config game cid msg server

        TunnelsMsg msg ->
            onTunnelsMsg config game cid msg server

        ServerRequest data ->
            updateServerRequest config (serverReceive data) server

        NotificationsMsg msg ->
            onNotificationsMsg config game cid msg server


handleSetBounce :
    Config msg
    -> CId
    -> Maybe Bounces.ID
    -> Server
    -> ServerUpdateResponse msg
handleSetBounce config cid maybeBounceId server =
    Update.fromModel <| setBounce maybeBounceId server


handleSetEndpoint :
    Config msg
    -> Maybe CId
    -> Server
    -> ServerUpdateResponse msg
handleSetEndpoint config cid server =
    Update.fromModel <| setEndpointCId cid server


handleSetActiveNIP :
    Config msg
    -> Network.NIP
    -> Server
    -> ServerUpdateResponse msg
handleSetActiveNIP config nip server =
    Update.fromModel <| setActiveNIP nip server


onFilesystemMsg :
    Config msg
    -> Game.Model
    -> CId
    -> StorageId
    -> Filesystem.Msg
    -> Server
    -> ServerUpdateResponse msg
onFilesystemMsg config game cid id msg server =
    case getStorage id server of
        Just storage ->
            let
                config_ =
                    filesystemConfig cid id config

                ( filesystem, cmd, dispatch ) =
                    Filesystem.update config_ msg <| getFilesystem storage

                storage_ =
                    setFilesystem filesystem storage

                server_ =
                    setStorage id storage_ server
            in
                ( server_, cmd, dispatch )

        Nothing ->
            Update.fromModel server


onLogsMsg :
    Config msg
    -> Game.Model
    -> CId
    -> Logs.Msg
    -> Server
    -> ServerUpdateResponse msg
onLogsMsg config game cid msg server =
    let
        config_ =
            logsConfig cid config

        ( logs, cmd, dispatch ) =
            Logs.update config_ msg <| getLogs server

        server_ =
            setLogs logs server
    in
        ( server_, cmd, dispatch )


onProcessesMsg :
    Config msg
    -> CId
    -> Processes.Msg
    -> Server
    -> ServerUpdateResponse msg
onProcessesMsg config cid msg server =
    let
        nip =
            getActiveNIP server

        config_ =
            processesConfig cid nip config

        ( processes, cmd, dispatch ) =
            Processes.update config_ msg <| getProcesses server

        server_ =
            setProcesses processes server
    in
        ( server_, cmd, dispatch )


onHardwareMsg :
    Config msg
    -> Game.Model
    -> CId
    -> Hardware.Msg
    -> Server
    -> ServerUpdateResponse msg
onHardwareMsg config game cid =
    Update.child
        { get = .hardware
        , set = (\hardware model -> { model | hardware = hardware })
        , toMsg = HardwareMsg >> ServerMsg cid >> config.toMsg
        , update = (Hardware.update game cid)
        }


onTunnelsMsg :
    Config msg
    -> Game.Model
    -> CId
    -> Tunnels.Msg
    -> Server
    -> ServerUpdateResponse msg
onTunnelsMsg config game cid =
    Update.child
        { get = .tunnels
        , set = (\tunnels model -> { model | tunnels = tunnels })
        , toMsg = TunnelsMsg >> ServerMsg cid >> config.toMsg
        , update = (Tunnels.update game)
        }


onNotificationsMsg :
    Config msg
    -> Game.Model
    -> CId
    -> Notifications.Msg
    -> Server
    -> ServerUpdateResponse msg
onNotificationsMsg config game cid =
    Update.child
        { get = .notifications
        , set = (\notifications model -> { model | notifications = notifications })
        , toMsg = NotificationsMsg >> ServerMsg cid >> config.toMsg
        , update = (Notifications.update game (Notifications.Server cid))
        }


updateServerRequest :
    Config msg
    -> Maybe ServerResponse
    -> Server
    -> ServerUpdateResponse msg
updateServerRequest config response server =
    case response of
        Just _ ->
            Update.fromModel server

        Nothing ->
            Update.fromModel server


handleJoinedServer :
    Config msg
    -> CId
    -> Value
    -> Model
    -> UpdateResponse msg
handleJoinedServer config cid value model =
    let
        decodeBootstrap =
            Decoders.Servers.server config.lastTick <|
                getGatewayCache cid model
    in
        case Decode.decodeValue decodeBootstrap value of
            Ok server ->
                let
                    dispatch =
                        if isGateway server then
                            cid
                                |> Account.NewGateway
                                |> Dispatch.account
                        else
                            Dispatch.none

                    model_ =
                        insert cid server model

                    dispatch_ =
                        Dispatch.batch
                            [ dispatch

                            --, Dispatch.web <| Web.JoinedServer cid
                            ]
                in
                    ( model_, Cmd.none, dispatch_ )

            Err reason ->
                let
                    log =
                        Debug.log ("▶ Server Bootstrap Error:\n" ++ reason) ""
                in
                    Update.fromModel model
