module Game.Servers.Models
    exposing
        ( Model
        , Servers
        , Server
        , ServerMeta(..)
        , GatewayMetadata
        , EndpointMetadata
        , AnalyzedMetadata
        , initialModel
        , get
        , insert
        , remove
        , safeUpdate
        , mapNetwork
        , getName
        , setName
        , getNIP
        , setNIP
        , getNIPs
        , setNIPs
        , getFilesystem
        , setFilesystem
        , getLogs
        , setLogs
        , getProcesses
        , setProcesses
        , getEndpoint
        , setEndpoint
        , getBounce
        , setBounce
        )

import Dict exposing (Dict)
import Game.Account.Bounces.Models as Bounces
import Game.Servers.Filesystem.Shared as Filesystem exposing (Filesystem)
import Game.Servers.Logs.Models as Logs
import Game.Servers.Processes.Models as Processes exposing (Processes)
import Game.Servers.Shared exposing (..)
import Game.Servers.Tunnels.Models as Tunnels
import Game.Servers.Web.Models as Web
import Game.Network.Types exposing (NIP)


type alias Model =
    { servers : Servers
    , network : NetworkMap
    }


type alias Servers =
    Dict ID Server


type alias Server =
    { name : String
    , nip : NIP
    , nips : List NIP
    , filesystem : Filesystem
    , logs : Logs.Model
    , processes : Processes
    , tunnels : Tunnels.Model
    , web : Web.Model
    , coordinates : Coordinates
    , meta : ServerMeta
    }


type ServerMeta
    = GatewayMeta GatewayMetadata
    | EndpointMeta EndpointMetadata
    | AnalyzedMeta AnalyzedMetadata


type alias GatewayMetadata =
    { bounce : Maybe Bounces.ID
    , endpoint : Maybe NIP
    }


type alias EndpointMetadata =
    {}


type alias AnalyzedMetadata =
    {}


type alias Coordinates =
    Float


type alias NetworkMap =
    Dict NIP ID


initialModel : Model
initialModel =
    { servers = Dict.empty
    , network = Dict.empty
    }



-- server crud


get : ID -> Model -> Maybe Server
get id { servers } =
    Dict.get id servers


insert : ID -> Server -> Model -> Model
insert id server ({ servers, network } as model) =
    let
        servers_ =
            Dict.insert id server servers

        network_ =
            List.foldl
                (flip Dict.insert id)
                network
                (server.nip :: server.nips)
    in
        model
            |> setServers servers_
            |> setNetwork network_


remove : ID -> Model -> Model
remove id ({ servers, network } as model) =
    let
        nips =
            servers
                |> Dict.get id
                |> Maybe.map (\server -> server.nip :: server.nips)
                |> Maybe.withDefault []

        servers_ =
            Dict.remove id servers

        network_ =
            List.foldl Dict.remove network nips

        model_ =
            model
                |> setServers servers_
                |> setNetwork network_
    in
        model_


safeUpdate : ID -> Server -> Model -> Model
safeUpdate id server model =
    case Dict.get id model.servers of
        Just _ ->
            insert id server model

        Nothing ->
            model


mapNetwork : NIP -> Model -> Maybe ID
mapNetwork nip { network } =
    Dict.get nip network



-- server getters/setters


getName : Server -> String
getName =
    .name


setName : String -> Server -> Server
setName name server =
    { server | name = name }


getNIP : Server -> NIP
getNIP =
    .nip


setNIP : NIP -> Server -> Server
setNIP nip server =
    { server | nip = nip }


getNIPs : Server -> List NIP
getNIPs server =
    server.nips


setNIPs : List NIP -> Server -> Server
setNIPs nips server =
    { server | nips = nips }


getFilesystem : Server -> Filesystem
getFilesystem =
    .filesystem


setFilesystem : Filesystem -> Server -> Server
setFilesystem filesystem model =
    { model | filesystem = filesystem }


getLogs : Server -> Logs.Model
getLogs =
    .logs


setLogs : Logs.Model -> Server -> Server
setLogs logs model =
    { model | logs = logs }


getProcesses : Server -> Processes
getProcesses =
    .processes


setProcesses : Processes -> Server -> Server
setProcesses processes model =
    { model | processes = processes }


getEndpoint : Server -> Maybe NIP
getEndpoint server =
    case server.meta of
        GatewayMeta meta ->
            meta.endpoint

        _ ->
            Nothing


setEndpoint : Maybe NIP -> Server -> Server
setEndpoint ip server =
    case server.meta of
        GatewayMeta meta ->
            let
                meta_ =
                    GatewayMeta { meta | endpoint = ip }
            in
                { server | meta = meta_ }

        _ ->
            server


getBounce : Server -> Maybe Bounces.ID
getBounce server =
    case server.meta of
        GatewayMeta meta ->
            meta.bounce

        _ ->
            Nothing


setBounce : Maybe Bounces.ID -> Server -> Server
setBounce id server =
    case server.meta of
        GatewayMeta meta ->
            let
                meta_ =
                    GatewayMeta { meta | bounce = id }
            in
                { server | meta = meta_ }

        _ ->
            server



-- internals


setServers : Servers -> Model -> Model
setServers servers model =
    { model | servers = servers }


setNetwork : NetworkMap -> Model -> Model
setNetwork network model =
    { model | network = network }
