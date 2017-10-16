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
    Dict CId ServerUid


type alias GatewayIds =
    Dict ServerUid CId


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
    , endpoints : List CId
    , endpoint : Maybe CId
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


getNIP : CId -> Model -> NIP
getNIP cid model =
    cid



-- gateway mapping information


insertGateway : CId -> ServerUid -> Model -> Model
insertGateway cid uid model =
    let
        gateways =
            Dict.insert cid uid model.gateways

        gatewayIds =
            Dict.insert uid cid model.gatewayIds
    in
        { model | gateways = gateways, gatewayIds = gatewayIds }


removeGateway : CId -> Model -> Model
removeGateway cid model =
    case Dict.get cid model.gateways of
        Just uid ->
            let
                gateways =
                    Dict.remove cid model.gateways

                gatewayIds =
                    Dict.remove uid model.gatewayIds
            in
                { model | gateways = gateways, gatewayIds = gatewayIds }

        Nothing ->
            model


getGateway : CId -> Model -> Maybe ServerUid
getGateway cid model =
    Dict.get cid model.gateways



-- session cid data


toSessionId : CId -> Model -> SessionId
toSessionId cid model =
    case getGateway cid model of
        Just uid ->
            uid

        Nothing ->
            remoteSessionId cid model


remoteSessionId : CId -> Model -> SessionId
remoteSessionId cid model =
    let
        nip =
            getNIP cid model
    in
        (Network.getId nip) ++ "@" ++ (Network.getIp nip)


getSessionId : CId -> Server -> Model -> SessionId
getSessionId cid server model =
    case server.ownership of
        GatewayOwnership data ->
            data.serverUid

        EndpointOwnership _ ->
            remoteSessionId cid model



-- elm structure-like functions


get : CId -> Model -> Maybe Server
get cid model =
    Dict.get (toSessionId cid model) model.servers


insert : CId -> Server -> Model -> Model
insert cid server model0 =
    let
        model1 =
            case server.ownership of
                GatewayOwnership data ->
                    insertGateway cid data.serverUid model0

                EndpointOwnership _ ->
                    model0

        servers =
            Dict.insert (getSessionId cid server model1) server model1.servers

        model_ =
            { model1 | servers = servers }
    in
        model_


remove : CId -> Model -> Model
remove cid model0 =
    let
        model1 =
            removeGateway cid model0

        servers =
            Dict.remove (toSessionId cid model0) model1.servers

        model_ =
            { model1 | servers = servers }
    in
        model_


keys : Model -> List CId
keys model =
    let
        toId model key =
            fromKey key model
    in
        model.servers
            |> Dict.keys
            |> List.filterMap (toId model)


fromKey : SessionId -> Model -> Maybe CId
fromKey key model =
    case String.split "@" key of
        [ serverUid ] ->
            Dict.get serverUid model.gatewayIds

        [ nid, ip ] ->
            Just ( nid, ip )

        _ ->
            Nothing


unsafeFromKey : SessionId -> Model -> CId
unsafeFromKey key model =
    case fromKey key model of
        Just cid ->
            cid

        _ ->
            Native.Panic.crash "WTF_WHERE_IS_IT"
                "Couldn't find the Server's CId for given SessionId."



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


getEndpointCId : Server -> Maybe CId
getEndpointCId server =
    case server.ownership of
        GatewayOwnership data ->
            data.endpoint

        _ ->
            Nothing


setEndpointCId : Maybe CId -> Server -> Server
setEndpointCId endpoint ({ ownership } as server) =
    let
        ownership_ =
            case ownership of
                GatewayOwnership data ->
                    GatewayOwnership { data | endpoint = endpoint }

                ownership ->
                    ownership
    in
        { server | ownership = ownership_ }


getEndpoints : Server -> Maybe (List CId)
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
