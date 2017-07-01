module Game.Servers.Models
    exposing
        ( Model
        , Servers
        , Server
        , Type(..)
        , NetworkMap
        , initialModel
        , setFilesystem
        , getFilesystem
        , setLogs
        , getLogs
        , setProcesses
        , getProcesses
        , get
        , getIP
        , safeUpdate
        , insert
        , mapNetwork
        )

import Dict exposing (Dict)
import Game.Servers.Shared exposing (..)
import Game.Network.Models as Network
import Game.Servers.Filesystem.Models exposing (Filesystem, initialFilesystem)
import Game.Servers.Logs.Models as Log exposing (Logs, initialLogs)
import Game.Servers.Processes.Models as Processes exposing (Processes, initialProcesses)


type alias Model =
    { servers : Servers
    , network : NetworkMap
    }


type alias Servers =
    Dict ID Server


type alias Server =
    { type_ : Type
    , ip : Network.IP
    , filesystem : Filesystem
    , logs : Logs
    , processes : Processes
    }


type Type
    = LocalServer
    | RemoteServer


type alias NetworkMap =
    Dict Network.IP ID


initialModel : Model
initialModel =
    { servers = Dict.empty
    , network = Dict.empty
    }


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



--


get : ID -> Model -> Maybe Server
get id { servers } =
    Dict.get id servers


getIP : Server -> Network.IP
getIP { ip } =
    ip


insert : ID -> Server -> Model -> Model
insert id server model =
    let
        servers_ =
            Dict.insert id server model.servers

        network_ =
            Dict.insert server.ip id model.network
    in
        model
            |> setServers servers_
            |> setNetwork network_


safeUpdate : ID -> Server -> Model -> Model
safeUpdate id server model =
    case Dict.get id model.servers of
        Just _ ->
            insert id server model

        Nothing ->
            model


mapNetwork : Network.IP -> Model -> Maybe ID
mapNetwork ip { network } =
    Dict.get ip network



-- internals


setServers : Servers -> Model -> Model
setServers servers model =
    { model | servers = servers }


setNetwork : NetworkMap -> Model -> Model
setNetwork network model =
    { model | network = network }
