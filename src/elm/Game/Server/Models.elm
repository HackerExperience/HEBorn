module Game.Server.Models exposing (..)

import Dict
import Game.Shared exposing (..)


type alias ServerID =
    ID


type alias ServerData =
    { id : ServerID
    , ip : IP
    }


type AnyServer
    = Server ServerData
    | NoServer


type alias Servers =
    Dict.Dict ServerID ServerData


type alias ServerModel =
    { servers : Servers
    }


createServer : ServerID -> IP -> ServerData
createServer id ip =
    { id = id
    , ip = ip
    }


storeServer : ServerModel -> ServerData -> Servers
storeServer model server =
    Dict.insert server.id server model.servers


existsServer : ServerModel -> ServerID -> Bool
existsServer model id =
    Dict.member id model.servers


getServerByID : ServerModel -> ServerID -> AnyServer
getServerByID model id =
    case Dict.get id model.servers of
        Just server ->
            Server server

        Nothing ->
            NoServer


initialServerModel : ServerModel
initialServerModel =
    { servers = Dict.empty }
