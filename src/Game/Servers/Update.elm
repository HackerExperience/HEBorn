module Game.Servers.Update exposing (..)

import Dict
import Json.Decode as Decode exposing (Value)
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events
import Game.Messages as Game
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
import Game.Servers.Requests.Server as Server
import Game.Network.Types exposing (NIP)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias ItemUpdateResponse =
    ( Server, Cmd ItemMsg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Bootstrap json ->
            onBootstrap game json model

        Item id msg ->
            updateItem game id msg model

        Event event ->
            broadcastEvent game event model



-- internals


updateItem : Game.Model -> ID -> ItemMsg -> Model -> UpdateResponse
updateItem game id msg ({ servers } as model) =
    case Dict.get id servers of
        Just server ->
            updateServer game id msg server
                |> Update.mapModel (flip (Dict.insert id) servers)
                |> Update.mapModel (\servers -> { model | servers = servers })
                |> Update.mapCmd (Item id)

        Nothing ->
            Update.fromModel model


broadcastEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
broadcastEvent game event ({ servers } as model) =
    let
        msg =
            ItemEvent event

        reducer id item (( servers, _, _ ) as updateState) =
            Update.fromModel item
                |> Update.andThen (updateServer game id msg)
                |> Update.mapModel (flip (Dict.insert id) servers)
                |> Update.mapCmd (Item id)
    in
        Dict.foldl reducer (Update.fromModel servers) servers
            |> Update.mapModel (\servers -> { model | servers = servers })


broadcastItemEvent :
    Game.Model
    -> ID
    -> Events.Event
    -> Server
    -> ItemUpdateResponse
broadcastItemEvent game id event server =
    -- updateFilesystem game (Filesystem.Event ev) server
    -- |> Update.andThen (updateLogs game (Logs.Event ev))
    -- |> Update.andThen (updateProcesses game (Processes.Event ev))
    -- |> Update.andThen (updateTunnels game (Tunnels.Event ev))
    Update.fromModel server


updateServer : Game.Model -> ID -> ItemMsg -> Server -> ItemUpdateResponse
updateServer game id msg server =
    case msg of
        SetBounce maybeId ->
            onSetBounce maybeId id server

        SetEndpoint maybeNip ->
            onSetEndpoint maybeNip id server

        FilesystemMsg msg ->
            updateFilesystem game msg server

        LogsMsg msg ->
            updateLogs game msg server

        ProcessesMsg msg ->
            updateProcesses game msg server

        TunnelsMsg msg ->
            updateTunnels game msg server

        ItemEvent ev ->
            Update.andThen (updateEvent game id ev)
                (broadcastItemEvent game id ev server)

        Request data ->
            updateResponse game (receive data) id server


updateFilesystem : Game.Model -> Filesystem.Msg -> Server -> ItemUpdateResponse
updateFilesystem game =
    Update.child
        { get = .filesystem
        , set = (\fs model -> { model | filesystem = fs })
        , toMsg = FilesystemMsg
        , update = (Filesystem.update game)
        }


updateLogs : Game.Model -> Logs.Msg -> Server -> ItemUpdateResponse
updateLogs game =
    Update.child
        { get = .logs
        , set = (\logs model -> { model | logs = logs })
        , toMsg = LogsMsg
        , update = (Logs.update game)
        }


updateProcesses : Game.Model -> Processes.Msg -> Server -> ItemUpdateResponse
updateProcesses game =
    Update.child
        { get = .processes
        , set = (\processes model -> { model | processes = processes })
        , toMsg = ProcessesMsg
        , update = (Processes.update game)
        }


updateTunnels : Game.Model -> Tunnels.Msg -> Server -> ItemUpdateResponse
updateTunnels game =
    Update.child
        { get = .tunnels
        , set = (\tunnels model -> { model | tunnels = tunnels })
        , toMsg = TunnelsMsg
        , update = (Tunnels.update game)
        }


updateEvent : Game.Model -> ID -> Events.Event -> Server -> ItemUpdateResponse
updateEvent game id msg server =
    -- no handled events yet
    Update.fromModel server


updateResponse : Game.Model -> Response -> ID -> Server -> ItemUpdateResponse
updateResponse game response id server =
    -- no handled responses yet
    Update.fromModel server


onBootstrap : Game.Model -> Value -> Model -> UpdateResponse
onBootstrap game json model =
    -- TODO: fix this it's only a POC on how not to do it
    -- maybe add this to Model
    let
        decodeIndex =
            Decode.decodeValue (Decode.list Decode.value)

        reducer serverData (( servers, _, _ ) as acc) =
            let
                msg =
                    LogsMsg <| Logs.Bootstrap serverData.logs

                server =
                    { name = "tmp"
                    , nip = ( "", "" )
                    , nips = [ ( "", "" ) ]
                    , filesystem = Filesystem.initialFilesystem
                    , logs = LogsModel.initialLogs
                    , processes = Processes.initialProcesses
                    , tunnels = Tunnels.initialModel
                    , meta =
                        GatewayMeta <| GatewayMetadata Nothing Nothing
                    , coordinates = 0
                    }
            in
                Update.andThen
                    (insert serverData.id server
                        >> updateItem game serverData.id msg
                    )
                    acc
    in
        decodeIndex json
            |> Result.withDefault []
            |> List.filterMap
                (Decode.decodeValue Server.decoder >> Result.toMaybe)
            |> List.foldl reducer (Update.fromModel model)


onSetBounce : Maybe Bounces.ID -> ID -> Server -> ItemUpdateResponse
onSetBounce maybeId id server =
    setBounce maybeId server
        |> Update.fromModel


onSetEndpoint : Maybe NIP -> ID -> Server -> ItemUpdateResponse
onSetEndpoint maybeNip id server =
    setEndpoint maybeNip server
        |> Update.fromModel
