module Game.Servers.Models exposing (..)

import Dict
import Utils.Dict as DictUtils
import Game.Shared exposing (..)
import Game.Servers.Filesystem.Models exposing (Filesystem, initialFilesystem)
import Game.Servers.Logs.Models as Log exposing (Logs, initialLogs)
import Game.Servers.Processes.Models as Processes exposing (Processes, initialProcesses)


-- DUMMIES

import Game.Servers.Filesystem.Dummy exposing (dummyFS)
import Game.Servers.Logs.Dummy exposing (dummyLogs)
import Game.Servers.Processes.Dummy exposing (dummyProcesses)


type alias ServerID =
    ID


type alias ServerData =
    { id : ServerID
    , ip : IP
    , filesystem : Filesystem
    , logs : Logs
    , processes : Processes
    }


type Server
    = StdServer ServerData
    | NoServer


type alias Model =
    Dict.Dict ServerID ServerData


invalidServerID : ServerID
invalidServerID =
    "invalidID"


invalidServer : ServerData
invalidServer =
    { id = invalidServerID
    , ip = "todo"
    , filesystem = initialFilesystem
    , logs = initialLogs
    , processes = initialProcesses
    }


getServerID : Server -> Maybe ServerID
getServerID server =
    case server of
        StdServer s ->
            Just s.id

        NoServer ->
            Nothing


getServerIDSafe : Server -> ServerID
getServerIDSafe server =
    Maybe.withDefault invalidServerID (getServerID server)


getServer : Server -> Maybe ServerData
getServer server =
    case server of
        StdServer s ->
            Just s

        NoServer ->
            Nothing


getServerSafe : Server -> ServerData
getServerSafe server =
    Maybe.withDefault invalidServer (getServer server)


addServer : Model -> ServerData -> Model
addServer servers server =
    Dict.insert server.id server servers


existsServer : Model -> ServerID -> Bool
existsServer servers id =
    Dict.member id servers


getServerByID : Model -> ServerID -> Server
getServerByID servers id =
    case Dict.get id servers of
        Just server ->
            StdServer server

        Nothing ->
            NoServer


initialModel : Model
initialModel =
    addServer
        -- DUMMY VALUE FOR PLAYING
        Dict.empty
        { id = "localhost"
        , ip = "localhost"
        , filesystem = dummyFS
        , logs = dummyLogs
        , processes = dummyProcesses
        }


getFilesystem : Server -> Maybe Filesystem
getFilesystem server =
    case server of
        StdServer s ->
            Just s.filesystem

        NoServer ->
            Nothing


getFilesystemSafe : Server -> Filesystem
getFilesystemSafe server =
    Maybe.withDefault initialFilesystem (getFilesystem server)


getLogs : Server -> Maybe Logs
getLogs server =
    case server of
        StdServer s ->
            Just s.logs

        NoServer ->
            Nothing


getProcesses : Server -> Maybe Processes
getProcesses server =
    case server of
        StdServer s ->
            Just s.processes

        NoServer ->
            Nothing


updateFilesystem : Server -> Filesystem -> Server
updateFilesystem server filesystem =
    case server of
        StdServer s ->
            StdServer { s | filesystem = filesystem }

        NoServer ->
            NoServer


updateLogs : Server -> Logs -> Server
updateLogs server logs =
    case server of
        StdServer s ->
            StdServer { s | logs = logs }

        NoServer ->
            NoServer


updateProcesses : Server -> Processes -> Server
updateProcesses server processes =
    case server of
        StdServer s ->
            StdServer { s | processes = processes }

        NoServer ->
            NoServer


updateServer : Model -> Server -> Model
updateServer servers server =
    case server of
        StdServer s ->
            DictUtils.safeUpdate
                (getServerIDSafe server)
                (getServerSafe server)
                servers

        NoServer ->
            servers
