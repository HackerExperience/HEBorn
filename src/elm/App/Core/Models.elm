module App.Core.Models exposing (..)

import Dict


{- Shared -}

type alias IP =
    String

type alias ID =
    String


{- Account -}


type alias AccountID =
    ID

type alias AuthData =
    {token : Maybe String}

type alias AccountModel =
    { id : Maybe AccountID
    , username : Maybe String
    , email : Maybe String
    , auth : AuthData
    }

getToken : AccountModel -> Maybe String
getToken model =
    model.auth.token

setToken : AccountModel -> Maybe String -> AccountModel
setToken model token =
    let
        auth_ = {token = token}
    in
        {model | auth = auth_}

isAuthenticated : AccountModel -> Bool
isAuthenticated model =
    case getToken model of
        Nothing ->
            False

        Just _ ->
            True


getTokenAsString : AccountModel -> String
getTokenAsString model =
    case getToken model of
        Just token ->
            token

        Nothing ->
            ""


initialAuth : AuthData
initialAuth =
    {token = Nothing}


initialAccountModel : AccountModel
initialAccountModel =
    { id = Nothing
    , username = Nothing
    , email = Nothing
    , auth = initialAuth
    }

{- Software -}

type alias FilePath =
    String

type FileVersion
    = FileVersionNumber Int
    | NoVersion

type FileSize
    = FileSizeNumber Int
    | NoSize

type alias RegularFileData =
    { name : String
    , extension : String
    , version : FileVersion
    , size : FileSize
    , path : FilePath}

type alias FolderData =
    { name : String
    , path : FilePath}

type File
    = RegularFile RegularFileData
    | RegularFolder FolderData

type alias Filesystem =
    Dict.Dict FilePath (List File)

type alias SoftwareModel =
    { filesystem : Filesystem }


getFilePath file =
    let
        path = case file of
            RegularFile file_ ->
                file_.path
            RegularFolder folder ->
                folder.path
    in
        path

getFileName file =
    let
        name = case file of
            RegularFile file_ ->
                file_.name
            RegularFolder folder ->
                folder.name
    in
        name


addFileToPath : SoftwareModel -> File -> Filesystem
addFileToPath model file =
    let
        path = getFilePath file
        filesOnPath = getFilesOnPath model path
        newFiles = filesOnPath ++ [file]
    in
        Dict.insert path newFiles model.filesystem


getFilesOnPath : SoftwareModel -> FilePath -> List File
getFilesOnPath model path =
    case Dict.get path model.filesystem of
        Just files ->
            files
        Nothing ->
            []

pathExists : SoftwareModel -> FilePath -> Bool
pathExists model path =
    case Dict.get path model.filesystem of
        Just _ ->
            True
        Nothing ->
            False

removeFileFromPath : SoftwareModel -> File -> Filesystem
removeFileFromPath model file =
    let
        path = getFilePath file
        name = getFileName file
        filesOnPath = getFilesOnPath model path
        newFiles = List.filter (\x -> (getFileName x) /= name) filesOnPath
    in
        Dict.insert path newFiles model.filesystem

listFilesystem : SoftwareModel -> String
listFilesystem model =
    toString model.filesystem

initialSoftwareModel =
    {filesystem = Dict.empty}

{- Server -}


type alias ServerID =
    ID

type alias ServerData =
    { id : ConnectionID
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
    {servers = Dict.empty}


{- NETWORK -}


type alias ConnectionID
    = ID

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
    , target_ip : IP}

type AnyConnection
    = Connection ConnectionData
    | NoConnection

type alias Connections =
    Dict.Dict ConnectionID ConnectionData

type alias NetworkModel =
    { gateway : Gateway
    , connections : Connections}


createGateway : AnyServer -> AnyServer -> Gateway
createGateway current previous =
    {current = current, previous = previous}


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
    , previous = NoServer}


initialConnections : Connections
initialConnections =
    Dict.empty


initialNetworkModel : NetworkModel
initialNetworkModel =
    { gateway = initialGateway
    , connections = initialConnections}

newConnection : ConnectionID
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
    , target_ip = target_ip}


storeConnection : NetworkModel -> ConnectionData -> Connections
storeConnection model connection =
    Dict.insert connection.id connection model.connections


{- CORE -}


type alias CoreModel =
    { account : AccountModel
    , server : ServerModel
    , network : NetworkModel
    , software : SoftwareModel
    }


initialModel : CoreModel
initialModel =
    { account = initialAccountModel
    , server = initialServerModel
    , network = initialNetworkModel
    , software = initialSoftwareModel
    }
