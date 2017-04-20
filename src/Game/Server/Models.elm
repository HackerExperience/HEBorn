module Game.Server.Models exposing (..)

import Dict
import Utils
import Game.Shared exposing (..)
import Game.Server.Filesystem.Models exposing (Filesystem, initialFilesystem)
import Game.Log.Models as Log exposing (Logs)


type alias ServerID =
    ID


type alias ServerData =
    { id : ServerID
    , ip : IP
    , filesystem : Filesystem
    , log : Logs
    }


type AnyServer
    = Server ServerData
    | NoServer


type alias ServerModel =
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


getServerID : AnyServer -> ServerID
getServerID server =
    case server of
        Server s ->
            s.id

        NoServer ->
            invalidServerID


getServer : AnyServer -> ServerData
getServer server =
    case server of
        Server s ->
            s

        NoServer ->
            invalidServer


storeServer : ServerModel -> ServerData -> ServerModel
storeServer model server =
    Dict.insert server.id server model


existsServer : ServerModel -> ServerID -> Bool
existsServer model id =
    Dict.member id model


getServerByID : ServerModel -> ServerID -> AnyServer
getServerByID model id =
    case Dict.get id model of
        Just server ->
            Server server

        Nothing ->
            NoServer


initialServerModel : ServerModel
initialServerModel =
    Dict.empty


getFilesystem : AnyServer -> Filesystem
getFilesystem server =
    case server of
        Server s ->
            s.filesystem

        NoServer ->
            initialFilesystem


updateFilesystem : AnyServer -> Filesystem -> AnyServer
updateFilesystem server filesystem =
    case server of
        Server s ->
            Server { s | filesystem = filesystem }

        NoServer ->
            NoServer


updateServer : ServerModel -> AnyServer -> ServerModel
updateServer model server =
    case server of
        Server s ->
            Utils.safeUpdateDict model (getServerID server) (getServer server)

        NoServer ->
            model
