module Game.Servers.Models exposing (..)

import Dict
import Utils
import Game.Shared exposing (..)
import Game.Servers.Filesystem.Models exposing (Filesystem, initialFilesystem)
import Game.Log.Models as Log exposing (Logs)


type alias ServerID =
    ID


type alias ServerData =
    { id : ServerID
    , ip : IP
    , filesystem : Filesystem
    , log : Logs
    }


type Server
    = StdServer ServerData
    | NoServer


type alias Servers =
    Dict.Dict ServerID ServerData


invalidServerID : ServerID
invalidServerID =
    "invalidID"


invalidServer : ServerData
invalidServer =
    { id = invalidServerID
    , ip = "todo"
    , filesystem = initialFilesystem
    , log = Dict.empty
    }


getServerID : Server -> ServerID
getServerID server =
    case server of
        StdServer s ->
            s.id

        NoServer ->
            invalidServerID


getServer : Server -> ServerData
getServer server =
    case server of
        StdServer s ->
            s

        NoServer ->
            invalidServer


addServer : Servers -> ServerData -> Servers
addServer servers server =
    Dict.insert server.id server servers


existsServer : Servers -> ServerID -> Bool
existsServer servers id =
    Dict.member id servers


getServerByID : Servers -> ServerID -> Server
getServerByID servers id =
    case Dict.get id servers of
        Just server ->
            StdServer server

        Nothing ->
            NoServer


initialServers : Servers
initialServers =
    Dict.empty


getFilesystem : Server -> Filesystem
getFilesystem server =
    case server of
        StdServer s ->
            s.filesystem

        NoServer ->
            initialFilesystem


updateFilesystem : Server -> Filesystem -> Server
updateFilesystem server filesystem =
    case server of
        StdServer s ->
            StdServer { s | filesystem = filesystem }

        NoServer ->
            NoServer


updateServer : Servers -> Server -> Servers
updateServer servers server =
    case server of
        StdServer s ->
            Utils.safeUpdateDict servers (getServerID server) (getServer server)

        NoServer ->
            servers
