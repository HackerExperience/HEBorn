module Game.Servers.Update exposing (..)

import Dict
import Json.Decode as Decode exposing (Value, decodeValue, list)
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events
import Events.Servers as ServersEvents
import Requests.Requests as Requests
import Game.Models as Game
import Game.Account.Bounces.Models as Bounces
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Update as Filesystem
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Logs.Models as Logs
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
import Game.Servers.Web.Messages as Web
import Game.Servers.Web.Models as Web
import Game.Servers.Web.Update as Web
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
            onRequest game (receive data) model


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
                    , filesystem =
                        Filesystem.bootstrap data.filesystem
                            Filesystem.initialModel
                    , logs =
                        Logs.bootstrap data.logs
                            Logs.initialModel
                    , processes =
                        Processes.initialProcesses
                    , tunnels =
                        Tunnels.bootstrap data.tunnels
                            Tunnels.initialModel
                    , web =
                        Web.initialModel
                    , meta =
                        GatewayMeta <| GatewayMetadata Nothing Nothing
                    }
            in
                ( data.id, server )
    in
        decodeValue (list Fetch.decoder) json
            |> Requests.report
            |> Maybe.withDefault []
            |> Debug.log "SERVER"
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


onRequest : Game.Model -> Maybe Response -> Model -> UpdateResponse
onRequest game response model =
    case response of
        Just response ->
            updateRequest game response model

        Nothing ->
            Update.fromModel model


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
            onLogsMsg game id msg server

        ProcessesMsg msg ->
            onProcessesMsg game msg server

        TunnelsMsg msg ->
            onTunnelsMsg game msg server

        WebMsg msg ->
            onWebMsg game msg server

        ServerEvent event ->
            onServerEvent game id event server

        ServerRequest data ->
            onServerRequest game id (serverReceive data) server


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


onLogsMsg : Game.Model -> ID -> Logs.Msg -> Server -> ServerUpdateResponse
onLogsMsg game id =
    Update.child
        { get = .logs
        , set = (\logs model -> { model | logs = logs })
        , toMsg = LogsMsg
        , update = (Logs.update game id)
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

onWebMsg : Game.Model -> Web.Msg -> Server -> ServerUpdateResponse
onWebMsg game =
    Update.child
        { get = .web
        , set = (\web model -> { model | web = web })
        , toMsg = WebMsg
        , update = (Web.update game)
        }

onServerEvent :
    Game.Model
    -> ID
    -> Events.Event
    -> Server
    -> ServerUpdateResponse
onServerEvent game id event server =
    if shouldRouteEvent id event then
        onLogsMsg game id (Logs.Event event) server
            -- |> Update.andThen (updateFilesystem game (Filesystem.Event ev))
            -- |> Update.andThen (updateProcesses game (Processes.Event ev))
            -- |> Update.andThen (updateTunnels game (Tunnels.Event ev))
            |> Update.andThen (updateServerEvent game id event)
    else
        Update.fromModel server


onServerRequest :
    Game.Model
    -> ID
    -> Maybe ServerResponse
    -> Server
    -> ServerUpdateResponse
onServerRequest game id response server =
    case response of
        Just response ->
            updateServerRequest game id response server

        Nothing ->
            Update.fromModel server


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


shouldRouteEvent : ID -> Events.Event -> Bool
shouldRouteEvent id event =
    case event of
        Events.ServersEvent (ServersEvents.ServerEvent id_ event) ->
            id == id_

        _ ->
            True
