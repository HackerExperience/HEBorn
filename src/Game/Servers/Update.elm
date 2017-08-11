module Game.Servers.Update exposing (..)

import Dict
import Json.Decode as Decode exposing (Value, decodeValue, list)
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events
import Game.Models as Game
import Game.Account.Bounces.Models as Bounces
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Update as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Logs.Models as LogsModel
import Game.Servers.Logs.Update as Logs
import Game.Servers.Messages exposing (..)
import Game.Servers.Models exposing (..)
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Processes.Models as Processes
import Game.Servers.Processes.Update as Processes
import Game.Servers.Requests exposing (..)
import Game.Servers.Shared exposing (..)
import Game.Servers.Tunnels.Messages as Tunnels
import Game.Servers.Tunnels.Models as Tunnels
import Game.Servers.Tunnels.Update as Tunnels
import Game.Servers.Requests.Fetch as Fetch
import Game.Network.Types exposing (NIP)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias ServerUpdateResponse =
    ( Server, Cmd ServerMsg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Bootstrap json ->
            onBootstrap game json model

        ServerMsg id msg ->
            onServerMsg game id msg model

        Event event ->
            onEvent game event model

        Request data ->
            updateRequest game (receive data) model


bootstrap : Game.Model -> Value -> Model -> Model
bootstrap game json model =
    let
        mapper data =
            let
                -- TODO: propagate bootstrap to remaining parts
                server =
                    { name = data.name
                    , coordinates = data.coordinates
                    , nip = data.nip
                    , nips = [ data.nip ]
                    , filesystem = Filesystem.initialFilesystem
                    , logs = Logs.bootstrap data.logs LogsModel.initialModel
                    , processes = Processes.initialProcesses
                    , tunnels = Tunnels.initialModel
                    , meta =
                        GatewayMeta <| GatewayMetadata Nothing Nothing
                    }
            in
                ( data.id, server )
    in
        decodeValue (list Fetch.decoder) json
            |> Result.withDefault []
            |> List.map mapper
            |> List.foldl (uncurry insert) model



-- collection message handlers


onBootstrap : Game.Model -> Value -> Model -> UpdateResponse
onBootstrap game json model =
    Update.fromModel <| bootstrap game json model


onServerMsg : Game.Model -> ID -> ServerMsg -> Model -> UpdateResponse
onServerMsg game id msg ({ servers } as model) =
    case Dict.get id servers of
        Just server ->
            updateServer game id msg server
                |> Update.mapModel (flip (Dict.insert id) servers)
                |> Update.mapModel (\servers -> { model | servers = servers })
                |> Update.mapCmd (ServerMsg id)

        Nothing ->
            Update.fromModel model


onEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
onEvent game event ({ servers } as model) =
    let
        msg =
            ServerEvent event

        reducer id server ( servers, cmd, dispatch ) =
            Update.fromModel server
                |> Update.andThen (updateServer game id msg)
                |> Update.mapModel (flip (Dict.insert id) servers)
                |> Update.mapCmd (ServerMsg id)
                |> Update.addCmd cmd
                |> Update.addDispatch dispatch
    in
        Dict.foldl reducer (Update.fromModel servers) servers
            |> Update.mapModel (\servers -> { model | servers = servers })
            |> Update.andThen (updateEvent game event)


updateEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
updateEvent game event model =
    Update.fromModel model


updateRequest : Game.Model -> Response -> Model -> UpdateResponse
updateRequest game data model =
    Update.fromModel model



--content message handlers


updateServer : Game.Model -> ID -> ServerMsg -> Server -> ServerUpdateResponse
updateServer game id msg server =
    case msg of
        SetBounce maybeId ->
            onSetBounce game id maybeId server

        SetEndpoint maybeNip ->
            onSetEndpoint game id maybeNip server

        FilesystemMsg msg ->
            onFilesystemMsg game id msg server

        LogsMsg msg ->
            onLogsMsg game msg server

        ProcessesMsg msg ->
            onProcessesMsg game msg server

        TunnelsMsg msg ->
            onTunnelsMsg game msg server

        ServerEvent event ->
            onServerEvent game id event server

        ServerRequest data ->
            updateServerRequest game id (serverReceive data) server


onSetBounce :
    Game.Model
    -> ID
    -> Maybe Bounces.ID
    -> Server
    -> ServerUpdateResponse
onSetBounce game id maybeId server =
    setBounce maybeId server
        |> Update.fromModel


onSetEndpoint :
    Game.Model
    -> ID
    -> Maybe NIP
    -> Server
    -> ServerUpdateResponse
onSetEndpoint game id maybeNip server =
    setEndpoint maybeNip server
        |> Update.fromModel


onFilesystemMsg :
    Game.Model
    -> ID
    -> Filesystem.Msg
    -> Server
    -> ServerUpdateResponse
onFilesystemMsg game id =
    Update.child
        { get = .filesystem
        , set = (\fs model -> { model | filesystem = fs })
        , toMsg = FilesystemMsg
        , update = (Filesystem.update game id)
        }


onLogsMsg : Game.Model -> Logs.Msg -> Server -> ServerUpdateResponse
onLogsMsg game =
    Update.child
        { get = .logs
        , set = (\logs model -> { model | logs = logs })
        , toMsg = LogsMsg
        , update = (Logs.update game)
        }


onProcessesMsg : Game.Model -> Processes.Msg -> Server -> ServerUpdateResponse
onProcessesMsg game =
    Update.child
        { get = .processes
        , set = (\processes model -> { model | processes = processes })
        , toMsg = ProcessesMsg
        , update = (Processes.update game)
        }


onTunnelsMsg : Game.Model -> Tunnels.Msg -> Server -> ServerUpdateResponse
onTunnelsMsg game =
    Update.child
        { get = .tunnels
        , set = (\tunnels model -> { model | tunnels = tunnels })
        , toMsg = TunnelsMsg
        , update = (Tunnels.update game)
        }


onServerEvent game id event server =
    -- updateFilesystem game (Filesystem.Event ev) server
    -- |> Update.andThen (updateLogs game (Logs.Event ev))
    -- |> Update.andThen (updateProcesses game (Processes.Event ev))
    -- |> Update.andThen (updateTunnels game (Tunnels.Event ev))
    updateServerEvent game id event server


updateServerEvent :
    Game.Model
    -> ID
    -> Events.Event
    -> Server
    -> ServerUpdateResponse
updateServerEvent game id event server =
    Update.fromModel server


updateServerRequest :
    Game.Model
    -> ID
    -> ServerResponse
    -> Server
    -> ServerUpdateResponse
updateServerRequest game id response server =
    Update.fromModel server
