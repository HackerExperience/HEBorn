module Game.Servers.Update exposing (..)

import Utils.React as React exposing (React)
import Json.Decode as Decode exposing (Value)
import Decoders.Servers
import Game.Meta.Types.Network as Network
import Game.Account.Bounces.Shared as Bounces
import Game.Servers.Notifications.Messages as Notifications
import Game.Servers.Notifications.Update as Notifications
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
import Game.Servers.Requests.Resync exposing (resyncRequest)
import Game.Servers.Config exposing (..)
import Game.Servers.Messages exposing (..)
import Game.Servers.Models exposing (..)
import Game.Servers.Shared exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


type alias ServerUpdateResponse msg =
    ( Server, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        ServerMsg cid msg ->
            onServerMsg config cid msg model

        Synced cid server ->
            ( insert cid server model, React.none )

        HandleResync cid ->
            onResync config cid model

        HandleJoinedServer cid value ->
            handleJoinedServer config cid value model


onServerMsg :
    Config msg
    -> CId
    -> ServerMsg
    -> Model
    -> UpdateResponse msg
onServerMsg config cid msg model =
    case get cid model of
        Just server ->
            server
                |> updateServer config cid model msg
                |> Tuple.mapFirst (flip (insert cid) model)

        Nothing ->
            ( model, React.none )


onResync : Config msg -> CId -> Model -> UpdateResponse msg
onResync config cid model =
    let
        handler result =
            case result of
                Ok ( cid, servers ) ->
                    config.toMsg <| Synced cid servers

                Err () ->
                    config.batchMsg []

        cmd =
            config
                |> resyncRequest cid
                    config.lastTick
                    (getGatewayCache cid model)
                |> Cmd.map handler
                |> React.cmd
    in
        ( model, cmd )


updateServer :
    Config msg
    -> CId
    -> Model
    -> ServerMsg
    -> Server
    -> ServerUpdateResponse msg
updateServer config cid model msg server =
    case msg of
        HandleSetBounce maybeBounceId ->
            handleSetBounce config cid maybeBounceId server

        HandleSetEndpoint remote ->
            handleSetEndpoint config remote server

        HandleSetActiveNIP nip ->
            handleSetActiveNIP config nip server

        FilesystemMsg storageId msg ->
            onFilesystemMsg config cid storageId msg server

        LogsMsg msg ->
            onLogsMsg config cid msg server

        ProcessesMsg msg ->
            onProcessesMsg config cid msg server

        HardwareMsg msg ->
            onHardwareMsg config cid msg server

        TunnelsMsg msg ->
            onTunnelsMsg config cid msg server

        NotificationsMsg msg ->
            onNotificationsMsg config cid msg server


handleSetBounce :
    Config msg
    -> CId
    -> Maybe Bounces.ID
    -> Server
    -> ServerUpdateResponse msg
handleSetBounce config cid maybeBounceId server =
    ( setBounce maybeBounceId server, React.none )


handleSetEndpoint :
    Config msg
    -> Maybe CId
    -> Server
    -> ServerUpdateResponse msg
handleSetEndpoint config cid server =
    ( setEndpointCId cid server, React.none )


handleSetActiveNIP :
    Config msg
    -> Network.NIP
    -> Server
    -> ServerUpdateResponse msg
handleSetActiveNIP config nip server =
    ( setActiveNIP nip server, React.none )


onFilesystemMsg :
    Config msg
    -> CId
    -> StorageId
    -> Filesystem.Msg
    -> Server
    -> ServerUpdateResponse msg
onFilesystemMsg config cid id msg server =
    case getStorage id server of
        Just storage ->
            let
                config_ =
                    filesystemConfig cid id config

                ( filesystem, cmd ) =
                    Filesystem.update config_ msg <| getFilesystem storage

                storage_ =
                    setFilesystem filesystem storage

                server_ =
                    setStorage id storage_ server
            in
                ( server_, cmd )

        Nothing ->
            ( server, React.none )


onLogsMsg :
    Config msg
    -> CId
    -> Logs.Msg
    -> Server
    -> ServerUpdateResponse msg
onLogsMsg config cid msg server =
    let
        config_ =
            logsConfig cid config

        ( logs, cmd ) =
            Logs.update config_ msg <| getLogs server

        server_ =
            setLogs logs server
    in
        ( server_, cmd )


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

        ( processes, cmd ) =
            Processes.update config_ msg <| getProcesses server

        server_ =
            setProcesses processes server
    in
        ( server_, cmd )


onHardwareMsg :
    Config msg
    -> CId
    -> Hardware.Msg
    -> Server
    -> ServerUpdateResponse msg
onHardwareMsg config cid msg server =
    let
        nip =
            getActiveNIP server

        config_ =
            hardwareConfig cid nip config

        ( hardware, cmd ) =
            Hardware.update config_ msg <| getHardware server

        server_ =
            setHardware hardware server
    in
        ( server_, cmd )


onTunnelsMsg :
    Config msg
    -> CId
    -> Tunnels.Msg
    -> Server
    -> ServerUpdateResponse msg
onTunnelsMsg config cid msg server =
    let
        config_ =
            tunnelsConfig cid config

        ( tunnels, cmd ) =
            Tunnels.update config_ msg <| getTunnels server

        server_ =
            setTunnels tunnels server
    in
        ( server_, cmd )


onNotificationsMsg :
    Config msg
    -> CId
    -> Notifications.Msg
    -> Server
    -> ServerUpdateResponse msg
onNotificationsMsg config cid msg server =
    let
        config_ =
            notificationsConfig cid config

        ( notifications, cmd ) =
            Notifications.update config_ msg <| getNotifications server

        model_ =
            setNotifications notifications server
    in
        ( model_, cmd )


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
                    model_ =
                        insert cid server model

                    cmd =
                        if isGateway server then
                            React.msg <| config.onNewGateway cid
                        else
                            React.none
                in
                    ( model_, cmd )

            Err reason ->
                let
                    log =
                        Debug.log ("▶ Server Bootstrap Error:\n" ++ reason) ""
                in
                    ( model, React.none )
