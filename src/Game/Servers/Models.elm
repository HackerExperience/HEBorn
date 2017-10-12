module Game.Servers.Models exposing (..)

import Dict exposing (Dict)
import Native.Panic
import Game.Account.Bounces.Models as Bounces
import Game.Servers.Filesystem.Shared as Filesystem exposing (Filesystem)
import Game.Servers.Logs.Models as Logs
import Game.Servers.Processes.Models as Processes
import Game.Servers.Shared exposing (..)
import Game.Servers.Tunnels.Models as Tunnels
import Game.Network.Types as Network exposing (NIP)
import Game.Notifications.Models as Notifications


type alias Model =
    { gateways : Gateways
    , gatewayIds : GatewayIds
    , servers : Servers
    }


type alias ServerUid =
    String


type alias Gateways =
    Dict ID ServerUid


type alias GatewayIds =
    Dict ServerUid ID


type alias SessionId =
    String


type alias Servers =
    Dict SessionId Server


type alias Server =
    { name : String
    , type_ : ServerType
    , nips : List NIP
    , coordinates : Maybe Coordinates
    , filesystem : Filesystem
    , logs : Logs.Model
    , processes : Processes.Model
    , tunnels : Tunnels.Model
    , ownership : Ownership
    , notifications : Notifications.Model
    }


type alias Coordinates =
    Float


type ServerType
    = Desktop
    | Mobile


type Ownership
    = GatewayOwnership GatewayData
    | EndpointOwnership EndpointData


type alias GatewayData =
    { serverUid : ServerUid
    , endpoints : List ID
    , endpoint : Maybe ID
    }


type alias EndpointData =
    { bounce : Maybe Bounces.ID
    , analyzed : Maybe AnalyzedEndpoint
    }


type alias AnalyzedEndpoint =
    {}


initialModel : Model
initialModel =
    { gateways = Dict.empty
    , gatewayIds = Dict.empty
    , servers = Dict.empty
    }


toNip : ID -> NIP
toNip =
    -- do not remove this function, it'll be useful
    -- once we include more data on id
    identity



-- gateway mapping information


insertGateway : ID -> ServerUid -> Model -> Model
insertGateway id uid model =
    let
        gateways =
            Dict.insert id uid model.gateways

        gatewayIds =
            Dict.insert uid id model.gatewayIds
    in
        { model | gateways = gateways, gatewayIds = gatewayIds }


removeGateway : ID -> Model -> Model
removeGateway id model =
    case Dict.get id model.gateways of
        Just uid ->
            let
                gateways =
                    Dict.remove id model.gateways

                gatewayIds =
                    Dict.remove uid model.gatewayIds
            in
                { model | gateways = gateways, gatewayIds = gatewayIds }

        Nothing ->
            model


getGateway : ID -> Model -> Maybe ServerUid
getGateway id model =
    Dict.get id model.gateways



-- session id data


toSessionId : ID -> Model -> SessionId
toSessionId id model =
    case getGateway id model of
        Just uid ->
            uid

        Nothing ->
            remoteSessionId id


remoteSessionId : ID -> SessionId
remoteSessionId id =
    let
        nip =
            toNip id
    in
        (Network.getId nip) ++ "@" ++ (Network.getIp nip)


getSessionId : ID -> Server -> SessionId
getSessionId id server =
    case server.ownership of
        GatewayOwnership data ->
            data.serverUid

        EndpointOwnership _ ->
            remoteSessionId id



-- elm structure-like functions


get : ID -> Model -> Maybe Server
get id model =
    Dict.get (toSessionId id model) model.servers


insert : ID -> Server -> Model -> Model
insert id server model0 =
    let
        model1 =
            case server.ownership of
                GatewayOwnership data ->
                    insertGateway id data.serverUid model0

                EndpointOwnership _ ->
                    model0

        servers =
            Dict.insert (getSessionId id server) server model1.servers

        model_ =
            { model1 | servers = servers }
    in
        model_


remove : ID -> Model -> Model
remove id model0 =
    let
        model1 =
            removeGateway id model0

        servers =
            Dict.remove (toSessionId id model0) model1.servers

        model_ =
            { model1 | servers = servers }
    in
        model_


keys : Model -> List ID
keys model =
    let
        toId model key =
            fromKey key model
    in
        model.servers
            |> Dict.keys
            |> List.filterMap (toId model)


fromKey : SessionId -> Model -> Maybe ID
fromKey key model =
    case String.split "@" key of
        [ serverUid ] ->
            Dict.get serverUid model.gatewayIds

        [ nid, ip ] ->
            Just ( nid, ip )

        _ ->
            Nothing


unsafeFromKey : SessionId -> Model -> ID
unsafeFromKey key model =
    case fromKey key model of
        Just id ->
            id

        _ ->
            Native.Panic.crash "WTF_WHERE_IS_IT" "Couldn't find the Server.ID for given SessionId."



------ server getters/setters


getName : Server -> String
getName =
    .name


setName : String -> Server -> Server
setName name server =
    { server | name = name }


getNIPs : Server -> List NIP
getNIPs server =
    server.nips


setNIPs : List NIP -> Server -> Server
setNIPs nips server =
    { server | nips = nips }


getFilesystem : Server -> Filesystem
getFilesystem =
    .filesystem


setFilesystem : Filesystem -> Server -> Server
setFilesystem filesystem model =
    { model | filesystem = filesystem }


getLogs : Server -> Logs.Model
getLogs =
    .logs


setLogs : Logs.Model -> Server -> Server
setLogs logs model =
    { model | logs = logs }


getProcesses : Server -> Processes.Model
getProcesses =
    .processes


setProcesses : Processes.Model -> Server -> Server
setProcesses processes model =
    { model | processes = processes }


getEndpoint : Server -> Maybe ID
getEndpoint server =
    case server.ownership of
        GatewayOwnership data ->
            data.endpoint

        _ ->
            Nothing


setEndpoint : Maybe ID -> Server -> Server
setEndpoint endpoint ({ ownership } as server) =
    let
        ownership_ =
            case ownership of
                GatewayOwnership data ->
                    GatewayOwnership { data | endpoint = endpoint }

                ownership ->
                    ownership
    in
        { server | ownership = ownership_ }


getEndpoints : Server -> Maybe (List ID)
getEndpoints server =
    case server.ownership of
        GatewayOwnership data ->
            Just data.endpoints

        _ ->
            Nothing


getBounce : Server -> Maybe Bounces.ID
getBounce server =
    case server.ownership of
        EndpointOwnership data ->
            data.bounce

        _ ->
            Nothing


setBounce : Maybe Bounces.ID -> Server -> Server
setBounce bounce ({ ownership } as server) =
    let
        ownership_ =
            case ownership of
                EndpointOwnership data ->
                    EndpointOwnership { data | bounce = bounce }

                ownership ->
                    ownership
    in
        { server | ownership = ownership_ }


isGateway : Server -> Bool
isGateway { ownership } =
    case ownership of
        GatewayOwnership _ ->
            True

        EndpointOwnership _ ->
            False
