module Game.Servers.Models exposing (..)

import Dict exposing (Dict)
import Set exposing (Set)
import Utils.Maybe as Maybe
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Logs.Models as Logs
import Game.Servers.Processes.Models as Processes
import Game.Servers.Tunnels.Models as Tunnels
import Game.Servers.Hardware.Models as Hardware
import Game.Servers.Notifications.Models as Notifications
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Shared exposing (..)


type alias Model =
    { gateways : Gateways
    , servers : Servers
    }


type alias Gateways =
    Dict Id GatewayCache


type alias GatewayCache =
    { activeNIP : NIP
    , nips : List NIP
    , endpoints : Set EndpointAddress
    }


type alias Servers =
    Dict SessionId Server


type alias Server =
    { name : String
    , type_ : ServerType
    , nips : List NIP
    , activeNIP : NIP
    , coordinates : Maybe Coordinates
    , mainStorage : StorageId
    , storages : Storages
    , logs : Logs.Model
    , bounce : Maybe Bounces.ID
    , processes : Processes.Model
    , tunnels : Tunnels.Model
    , ownership : Ownership
    , notifications : Notifications.Model
    , hardware : Hardware.Model
    }


type alias Coordinates =
    Float


type alias Storages =
    Dict StorageId Storage


type alias Storage =
    { name : String
    , filesystem : Filesystem.Model
    }


type ServerType
    = Desktop
    | DesktopCampaign
    | Mobile


type Ownership
    = GatewayOwnership GatewayData
    | EndpointOwnership EndpointData


type alias GatewayData =
    { endpoints : Set EndpointAddress
    , endpoint : Maybe CId
    }


type alias EndpointData =
    { analyzed : Maybe AnalyzedEndpoint
    }


type alias AnalyzedEndpoint =
    {}


initialModel : Model
initialModel =
    { gateways = Dict.empty
    , servers = Dict.empty
    }



-- gateway mapping information


insertGateway : Id -> NIP -> List NIP -> Set EndpointAddress -> Model -> Model
insertGateway id activeNIP nips endpoints model =
    let
        cache =
            GatewayCache activeNIP nips endpoints

        gateways =
            Dict.insert id cache model.gateways
    in
        { model | gateways = gateways }


removeGateway : CId -> Model -> Model
removeGateway cid model =
    let
        sid =
            toSessionId cid
    in
        case Dict.get sid model.gateways of
            Just cache ->
                let
                    gateways =
                        Dict.remove sid model.gateways
                in
                    { model | gateways = gateways }

            Nothing ->
                model


getGatewayCache : CId -> Model -> Maybe GatewayCache
getGatewayCache cid model =
    Dict.get (toSessionId cid) model.gateways


getServerId : CId -> Model -> Maybe Id
getServerId cid model =
    case cid of
        GatewayCId id ->
            Just id

        EndpointCId _ ->
            Nothing



-- session cid data


toSessionId : CId -> SessionId
toSessionId cid =
    case cid of
        GatewayCId id ->
            id

        EndpointCId ( id, ip ) ->
            id ++ "@" ++ ip



-- elm structure-like functions


get : CId -> Model -> Maybe Server
get cid model =
    Dict.get (toSessionId cid) model.servers


insert : CId -> Server -> Model -> Model
insert cid server model0 =
    let
        model1 =
            case server.ownership of
                GatewayOwnership data ->
                    case cid of
                        GatewayCId id ->
                            insertGateway id
                                server.activeNIP
                                []
                                data.endpoints
                                model0

                        EndpointCId _ ->
                            model0

                EndpointOwnership _ ->
                    model0

        servers =
            Dict.insert (toSessionId cid) server model1.servers

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
            Dict.remove (toSessionId cid) model1.servers

        model_ =
            { model1 | servers = servers }
    in
        model_


keys : Model -> List CId
keys model =
    model.servers
        |> Dict.keys
        |> List.map fromKey


fromKey : SessionId -> CId
fromKey key =
    case String.split "@" key of
        [ nid, ip ] ->
            EndpointCId ( nid, ip )

        _ ->
            GatewayCId key



-- server getters/setters


getName : Server -> String
getName =
    .name


setName : String -> Server -> Server
setName name server =
    { server | name = name }


getActiveNIP : Server -> NIP
getActiveNIP { activeNIP } =
    activeNIP


getNIPs : Server -> List NIP
getNIPs server =
    server.nips


setNIPs : List NIP -> Server -> Server
setNIPs nips server =
    { server | nips = nips }


listStorages : Server -> List ( StorageId, Storage )
listStorages server =
    Dict.toList server.storages


getMainStorageId : Server -> StorageId
getMainStorageId =
    .mainStorage


getMainStorage : Server -> Maybe Storage
getMainStorage server =
    getStorage (getMainStorageId server) server


getStorage : StorageId -> Server -> Maybe Storage
getStorage id server =
    Dict.get id server.storages


setStorage : StorageId -> Storage -> Server -> Server
setStorage id storages server =
    { server | storages = Dict.insert id storages server.storages }


getStorageName : Storage -> String
getStorageName =
    .name


setStorageName : String -> Storage -> Storage
setStorageName name storage =
    { storage | name = name }


getFilesystem : Storage -> Filesystem.Model
getFilesystem =
    .filesystem


setFilesystem : Filesystem.Model -> Storage -> Storage
setFilesystem fs storage =
    { storage | filesystem = fs }


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
setEndpointCId cid ({ ownership } as server) =
    let
        ownership_ =
            case ownership of
                GatewayOwnership data ->
                    GatewayOwnership <|
                        { data | endpoint = cid }

                ownership ->
                    ownership
    in
        { server | ownership = ownership_ }


addEndpointCId : CId -> Server -> Server
addEndpointCId cid ({ ownership } as server) =
    let
        ownership_ =
            case ( ownership, cid ) of
                ( GatewayOwnership data, EndpointCId addr ) ->
                    GatewayOwnership <|
                        { data
                            | endpoints =
                                Set.insert addr data.endpoints
                        }

                _ ->
                    ownership
    in
        { server | ownership = ownership_ }


removeEndpointCId : CId -> Server -> Server
removeEndpointCId cid ({ ownership } as server) =
    let
        ownership_ =
            case ( ownership, cid ) of
                ( GatewayOwnership data, EndpointCId addr ) ->
                    GatewayOwnership <|
                        { data
                            | endpoints =
                                Set.remove addr data.endpoints
                            , endpoint =
                                if data.endpoint == Just cid then
                                    Nothing
                                else
                                    data.endpoint
                        }

                _ ->
                    ownership
    in
        { server | ownership = ownership_ }


setActiveNIP : NIP -> Server -> Server
setActiveNIP nip server =
    { server | activeNIP = nip }


getEndpoints : Server -> Maybe (List CId)
getEndpoints server =
    case server.ownership of
        GatewayOwnership data ->
            data.endpoints
                |> Set.toList
                |> List.map EndpointCId
                |> Just

        _ ->
            Nothing


getBounce : Server -> Maybe Bounces.ID
getBounce server =
    server.bounce


getActiveBounce : Server -> Model -> Maybe Bounces.ID
getActiveBounce server model =
    case (getEndpointCId server) of
        Nothing ->
            getBounce server

        Just cid ->
            model
                |> get cid
                |> Maybe.andThen (getBounce)


setActiveBounce : Server -> Maybe Bounces.ID -> Server
setActiveBounce server bounceId =
    case (getEndpointCId server) of
        Nothing ->
            { server | bounce = bounceId }

        Just cid ->
            --can not change bounces being used in a connection
            server


setBounce : Maybe Bounces.ID -> Server -> Server
setBounce bounce server =
    { server | bounce = bounce }


isGateway : Server -> Bool
isGateway { ownership } =
    case ownership of
        GatewayOwnership _ ->
            True

        EndpointOwnership _ ->
            False


isFreeplay : Server -> Bool
isFreeplay server =
    case server.type_ of
        Desktop ->
            True

        Mobile ->
            True

        DesktopCampaign ->
            False


getHardware : Server -> Hardware.Model
getHardware server =
    server.hardware


setHardware : Hardware.Model -> Server -> Server
setHardware hardware server =
    { server | hardware = hardware }


getNotifications : Server -> Notifications.Model
getNotifications =
    .notifications


setNotifications : Notifications.Model -> Server -> Server
setNotifications notifications server =
    { server | notifications = notifications }


getTunnels : Server -> Tunnels.Model
getTunnels =
    .tunnels


setTunnels : Tunnels.Model -> Server -> Server
setTunnels tunnels server =
    { server | tunnels = tunnels }


getContextServer : Context -> Model -> ( CId, Server ) -> Maybe ( CId, Server )
getContextServer context servers ( gatewayCId, gateway ) =
    let
        endpointCId =
            getEndpointCId gateway

        maybeEndpoint =
            Maybe.andThen (flip get servers) endpointCId
    in
        case context of
            Gateway ->
                Just ( gatewayCId, gateway )

            Endpoint ->
                Maybe.uncurry endpointCId maybeEndpoint


getType : Server -> ServerType
getType =
    .type_
