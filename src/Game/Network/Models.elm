module Game.Network.Models exposing (..)

import Dict
import Game.Shared exposing (..)
import Game.Servers.Models exposing (Server(..), ServerID)


type alias ConnectionID =
    ID


type alias Gateway =
    { current : Server
    , previous : Server
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


type Connection
    = StdConnection ConnectionData
    | NoConnection


type alias Connections =
    Dict.Dict ConnectionID ConnectionData


type alias Model =
    { gateway : Gateway
    , connections : Connections
    }


createGateway : Server -> Server -> Gateway
createGateway current previous =
    { current = current, previous = previous }


getCurrentGateway : Model -> Server
getCurrentGateway model =
    model.gateway.current


getPreviousGateway : Model -> Server
getPreviousGateway model =
    model.gateway.previous


setCurrentGateway : Model -> Server -> Gateway
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


initialModel : Model
initialModel =
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


storeConnection : Model -> ConnectionData -> Connections
storeConnection model connection =
    Dict.insert connection.id connection model.connections
