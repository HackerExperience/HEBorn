module Game.Network.Models exposing (..)

import Dict
import Game.Shared exposing (..)
import Game.Servers.Models as Servers exposing (Server)


type alias ConnectionID =
    ID


type alias Gateway =
    { current : Maybe Server
    , previous : Maybe Server
    }


type ConnectionType
    = ConnectionFTP
    | ConnectionSSH
    | ConnectionX11
    | UnknownConnectionType


type alias ConnectionData =
    { id : ConnectionID
    , connection_type : ConnectionType
    , source_id : Servers.ID
    , source_ip : IP
    , target_id : Servers.ID
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


createGateway : Maybe Server -> Maybe Server -> Gateway
createGateway current previous =
    { current = current, previous = previous }


getCurrentGateway : Model -> Maybe Server
getCurrentGateway model =
    model.gateway.current


getPreviousGateway : Model -> Maybe Server
getPreviousGateway model =
    model.gateway.previous


setCurrentGateway : Server -> Model -> Gateway
setCurrentGateway gateway model =
    createGateway (Just gateway) model.gateway.current


initialGateway : Gateway
initialGateway =
    { current = Nothing
    , previous = Nothing
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
    -> Servers.ID
    -> IP
    -> Servers.ID
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
