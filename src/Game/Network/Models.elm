module Game.Network.Models exposing (..)

import Dict
import Game.Shared exposing (..)
import Game.Server.Models exposing (AnyServer(..), ServerID)


type alias ConnectionID =
    ID


type alias Gateway =
    { current : AnyServer
    , previous : AnyServer
    }


type ConnectionType
    = ConnectionFTP
    | ConnectionSSH
    | ConnectionX11
    | UnknownConnectionType


type alias ConnectionData =
    { id : ConnectionID
    , connection_type : ConnectionType
    , source_id : ServerID
    , source_ip : IP
    , target_id : ServerID
    , target_ip : IP
    }


type AnyConnection
    = Connection ConnectionData
    | NoConnection


type alias Connections =
    Dict.Dict ConnectionID ConnectionData


type alias NetworkModel =
    { gateway : Gateway
    , connections : Connections
    }


createGateway : AnyServer -> AnyServer -> Gateway
createGateway current previous =
    { current = current, previous = previous }


getCurrentGateway : NetworkModel -> AnyServer
getCurrentGateway model =
    model.gateway.current


getPreviousGateway : NetworkModel -> AnyServer
getPreviousGateway model =
    model.gateway.previous


setCurrentGateway : NetworkModel -> AnyServer -> Gateway
setCurrentGateway model gateway =
    createGateway gateway model.gateway.current


initialGateway : Gateway
initialGateway =
    { current = NoServer
    , previous = NoServer
    }


initialConnections : Connections
initialConnections =
    Dict.empty


initialNetworkModel : NetworkModel
initialNetworkModel =
    { gateway = initialGateway
    , connections = initialConnections
    }


newConnection :
    ConnectionID
    -> ConnectionType
    -> ServerID
    -> IP
    -> ServerID
    -> IP
    -> ConnectionData
newConnection id type_ source_id source_ip target_id target_ip =
    { id = id
    , connection_type = type_
    , source_id = source_id
    , source_ip = source_ip
    , target_id = target_id
    , target_ip = target_ip
    }


storeConnection : NetworkModel -> ConnectionData -> Connections
storeConnection model connection =
    Dict.insert connection.id connection model.connections
