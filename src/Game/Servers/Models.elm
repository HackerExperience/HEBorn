module Game.Servers.Models
    exposing
        ( Model
        , Servers
        , Server
        , Type(..)
        , initialModel
        , get
        , insert
        , remove
        , safeUpdate
        , mapNetwork
        , getName
        , setName
        , getType
        , getIP
        , setIP
        , getFilesystem
        , setFilesystem
        , getLogs
        , setLogs
        , getProcesses
        , setProcesses
        , getTunnels
        , setTunnels
        , getEndpoint
        , setEndpoint
        , getBounce
        , setBounce
        , getTunnel
        , setTunnel
        )

import Dict exposing (Dict)
import Game.Account.Bounces.Models as Bounces
import Game.Servers.Filesystem.Models exposing (Filesystem, initialFilesystem)
import Game.Servers.Logs.Models as Log exposing (Logs, initialLogs)
import Game.Servers.Processes.Models as Processes exposing (Processes, initialProcesses)
import Game.Servers.Shared exposing (..)
import Game.Servers.Tunnels.Models as Tunnels exposing (initialModel)
import Game.Network.Types exposing (IP)


type alias Model =
    { servers : Servers
    , network : NetworkMap
    }


type alias Servers =
    Dict ID Server


type alias Server =
    { name : String
    , type_ : Type
    , ip : IP
    , filesystem : Filesystem
    , logs : Logs
    , processes : Processes
    , tunnels : Tunnels.Model
    , bounce : Maybe Bounces.ID
    , endpoint : Maybe IP
    }


type Type
    = LocalServer
    | RemoteServer


type alias NetworkMap =
    Dict IP ID


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
            Dict.insert server.ip id network
    in
        model
            |> setServers servers_
            |> setNetwork network_


remove : ID -> Model -> Model
remove id ({ servers, network } as model) =
    let
        ip =
            servers
                |> Dict.get id
                |> Maybe.map .ip
                |> Maybe.withDefault ""

        servers_ =
            Dict.remove id servers

        network_ =
            Dict.remove ip network

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


mapNetwork : IP -> Model -> Maybe ID
mapNetwork ip { network } =
    Dict.get ip network



-- server getters/setters


getName : Server -> String
getName =
    .name


setName : String -> Server -> Server
setName name server =
    { server | name = name }


getType : Server -> Type
getType =
    .type_


getIP : Server -> IP
getIP =
    .ip


setIP : IP -> Server -> Server
setIP ip server =
    { server | ip = ip }


getFilesystem : Server -> Filesystem
getFilesystem =
    .filesystem


setFilesystem : Filesystem -> Server -> Server
setFilesystem filesystem model =
    { model | filesystem = filesystem }


getLogs : Server -> Logs
getLogs =
    .logs


setLogs : Logs -> Server -> Server
setLogs logs model =
    { model | logs = logs }


getProcesses : Server -> Processes
getProcesses =
    .processes


setProcesses : Processes -> Server -> Server
setProcesses processes model =
    { model | processes = processes }


getTunnels : Server -> Tunnels.Model
getTunnels =
    .tunnels


setTunnels : Tunnels.Model -> Server -> Server
setTunnels tunnels model =
    { model | tunnels = tunnels }


getEndpoint : Server -> Maybe IP
getEndpoint =
    .endpoint


setEndpoint : Maybe IP -> Server -> Server
setEndpoint ip server =
    { server | endpoint = ip }


getBounce : Server -> Maybe Bounces.ID
getBounce =
    .bounce


setBounce : Maybe Bounces.ID -> Server -> Server
setBounce id server =
    { server | bounce = id }


getTunnel : Server -> Maybe Tunnels.Tunnel
getTunnel { bounce, endpoint, tunnels } =
    case endpoint of
        Just id ->
            Just <| Tunnels.get bounce id tunnels

        Nothing ->
            Nothing


setTunnel : Tunnels.Tunnel -> Server -> Server
setTunnel tunnel ({ bounce, endpoint, tunnels } as server) =
    case endpoint of
        Just id ->
            let
                tunnels_ =
                    Tunnels.insert bounce id tunnel tunnels
            in
                setTunnels tunnels_ server

        Nothing ->
            server



-- internals


setServers : Servers -> Model -> Model
setServers servers model =
    { model | servers = servers }


setNetwork : NetworkMap -> Model -> Model
setNetwork network model =
    { model | network = network }
