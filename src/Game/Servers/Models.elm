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


{-| Model de servers, contém dados específicos do server e mais alguns dados
que são mantidos em cache.
-}
type alias Model =
    { gateways : Gateways
    , servers : Servers
    , gatewayOfEndpoints : GatewayOfEndpoints
    }


{-| Dict com cache de cada gateway.
-}
type alias Gateways =
    Dict Id GatewayCache


{-| Dados em cache de um gateway.
-}
type alias GatewayCache =
    { activeNIP : NIP
    , nips : List NIP
    , endpoints : Set EndpointAddress
    }


{-| Dict com servidores.
-}
type alias Servers =
    Dict SessionId Server


{-| Dados de um servidor.
-}
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


{-| Coordenadas de um servidor.
-}
type alias Coordinates =
    Float


{-| Storages de um servidor.
-}
type alias Storages =
    Dict StorageId Storage


{-| Dados de uma storage, o nome ela e seu filesystem.
-}
type alias Storage =
    { name : String
    , filesystem : Filesystem.Model
    }


{-| Tipos de servidor.
-}
type ServerType
    = Desktop
    | DesktopCampaign
    | Mobile


{-| Dados do servidor que variam se o servidor é um gateway ou endpoint.
-}
type Ownership
    = GatewayOwnership GatewayData
    | EndpointOwnership EndpointData


{-| Dados específicos para gateways.
-}
type alias GatewayData =
    { endpoints : Set EndpointAddress
    , endpoint : Maybe CId
    }


{-| Dados específicos para endpoints.
-}
type alias EndpointData =
    { analyzed : Maybe AnalyzedEndpoint
    }


{-| Dados de um endpoint analisado.
-}
type alias AnalyzedEndpoint =
    {}


{-| Dict pra mapear endpoints para seus gateways, o window manager utiliza
muito isso pra alguns casos específicos de aplicativos.
-}
type alias GatewayOfEndpoints =
    Dict EndpointAddress Id


{-| Model inicial.
-}
initialModel : Model
initialModel =
    { gateways = Dict.empty
    , servers = Dict.empty
    , gatewayOfEndpoints = Dict.empty
    }


{-| Insere um server gateway na model.
-}
insertGateway : Id -> NIP -> List NIP -> Set EndpointAddress -> Model -> Model
insertGateway id activeNIP nips endpoints model =
    let
        cache =
            GatewayCache activeNIP nips endpoints

        gateways =
            Dict.insert id cache model.gateways

        gatewayOfEndpoints =
            Set.foldl (flip Dict.insert id)
                model.gatewayOfEndpoints
                endpoints
    in
        { model
            | gateways = gateways
            , gatewayOfEndpoints = gatewayOfEndpoints
        }


{-| Remove um server gateway na model.
-}
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


{-| Retorna o cache do server gateway.
-}
getGatewayCache : CId -> Model -> Maybe GatewayCache
getGatewayCache cid model =
    Dict.get (toSessionId cid) model.gateways


{-| Retorna o id do servidor, sempre retorna Nothing pra endpoints.
-}
getServerId : CId -> Model -> Maybe Id
getServerId cid model =
    case cid of
        GatewayCId id ->
            Just id

        EndpointCId _ ->
            Nothing


{-| Converte CId em SessionId.
-}
toSessionId : CId -> SessionId
toSessionId cid =
    case cid of
        GatewayCId id ->
            id

        EndpointCId ( id, ip ) ->
            id ++ "@" ++ ip


{-| Tenta pegar um servidor da model.
-}
get : CId -> Model -> Maybe Server
get cid model =
    Dict.get (toSessionId cid) model.servers


{-| Insere um servidor na model.
-}
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


{-| Remove server do servidor.
-}
remove : CId -> Model -> Model
remove cid model0 =
    let
        model1 =
            removeGateway cid model0

        servers =
            Dict.remove (toSessionId cid) model1.servers

        model2 =
            case cid of
                EndpointCId nip ->
                    let
                        gatewayOfEndpoints =
                            Dict.remove nip model1.gatewayOfEndpoints
                    in
                        { model1 | gatewayOfEndpoints = gatewayOfEndpoints }

                GatewayCId _ ->
                    model1
    in
        { model2 | servers = servers }


{-| Retorna lista de CIds do jogo.
-}
keys : Model -> List CId
keys model =
    model.servers
        |> Dict.keys
        |> List.map fromKey


{-| Converte SessionId em CId.
-}
fromKey : SessionId -> CId
fromKey key =
    case String.split "@" key of
        [ nid, ip ] ->
            EndpointCId ( nid, ip )

        _ ->
            GatewayCId key


{-| Retorna nome do servidor.
-}
getName : Server -> String
getName =
    .name


{-| Atualiza nome do servidor.
-}
setName : String -> Server -> Server
setName name server =
    { server | name = name }


{-| Retorna nip ativo do servidor.
-}
getActiveNIP : Server -> NIP
getActiveNIP { activeNIP } =
    activeNIP


{-| Retorna os nips do servidor.
-}
getNIPs : Server -> List NIP
getNIPs server =
    server.nips


{-| Atualiza os nips do servidor.
-}
setNIPs : List NIP -> Server -> Server
setNIPs nips server =
    { server | nips = nips }


{-| Retorna lista de storages do servidor.
-}
listStorages : Server -> List ( StorageId, Storage )
listStorages server =
    Dict.toList server.storages


{-| Retorna main storage do servidor.
-}
getMainStorageId : Server -> StorageId
getMainStorageId =
    .mainStorage


{-| Retorna main storage do servidor.
-}
getMainStorage : Server -> Maybe Storage
getMainStorage server =
    getStorage (getMainStorageId server) server


{-| Tenta pegar storage do servidor.
-}
getStorage : StorageId -> Server -> Maybe Storage
getStorage id server =
    Dict.get id server.storages


{-| Atualiza storage do servidor.
-}
setStorage : StorageId -> Storage -> Server -> Server
setStorage id storages server =
    { server | storages = Dict.insert id storages server.storages }


{-| Retorna nome da storage.
-}
getStorageName : Storage -> String
getStorageName =
    .name


{-| Atualiza nome da storage.
-}
setStorageName : String -> Storage -> Storage
setStorageName name storage =
    { storage | name = name }


{-| Retorna filesystem da storage.
-}
getFilesystem : Storage -> Filesystem.Model
getFilesystem =
    .filesystem


{-| Atualiza filesystem da storage.
-}
setFilesystem : Filesystem.Model -> Storage -> Storage
setFilesystem fs storage =
    { storage | filesystem = fs }


{-| Retorna logs do servidor.
-}
getLogs : Server -> Logs.Model
getLogs =
    .logs


{-| Atualiza logs do servidor.
-}
setLogs : Logs.Model -> Server -> Server
setLogs logs model =
    { model | logs = logs }


{-| Retorna processos do servidor.
-}
getProcesses : Server -> Processes.Model
getProcesses =
    .processes


{-| Atualiza processos do servidor.
-}
setProcesses : Processes.Model -> Server -> Server
setProcesses processes model =
    { model | processes = processes }


{-| Tenta pegar cid do endpoint do gateway.
-}
getEndpointCId : Server -> Maybe CId
getEndpointCId server =
    case server.ownership of
        GatewayOwnership data ->
            data.endpoint

        _ ->
            Nothing


{-| Atualiza cid do endpoint do gateway.
-}
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


{-| Adiciona endpoint ao gateway.
-}
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


{-| Reomve endpoint do gateway.
-}
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


{-| Atualiza nip ativo do servidor.
-}
setActiveNIP : NIP -> Server -> Server
setActiveNIP nip server =
    { server | activeNIP = nip }


{-| Tenta pegar os endpoints de um servidor.
-}
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


{-| Tenta pegar os bounces de um servidor.
-}
getBounce : Server -> Maybe Bounces.ID
getBounce server =
    server.bounce


{-| Tenta pegar o bounce ativo de um servidor.
-}
getActiveBounce : Server -> Model -> Maybe Bounces.ID
getActiveBounce server model =
    case (getEndpointCId server) of
        Nothing ->
            getBounce server

        Just cid ->
            model
                |> get cid
                |> Maybe.andThen (getBounce)


{-| Atualiza o bounce ativo.
-}
setActiveBounce : Server -> Maybe Bounces.ID -> Server
setActiveBounce server bounceId =
    case (getEndpointCId server) of
        Nothing ->
            { server | bounce = bounceId }

        Just cid ->
            --can not change bounces being used in a connection
            server


{-| Atualiza os bounces de um servidor.
-}
setBounce : Maybe Bounces.ID -> Server -> Server
setBounce bounce server =
    { server | bounce = bounce }


{-| Retorna se o server é um gateway.
-}
isGateway : Server -> Bool
isGateway { ownership } =
    case ownership of
        GatewayOwnership _ ->
            True

        EndpointOwnership _ ->
            False


{-| Retornar se o server é freeplay.
-}
isFreeplay : Server -> Bool
isFreeplay server =
    case server.type_ of
        Desktop ->
            True

        Mobile ->
            True

        DesktopCampaign ->
            False


{-| Tenta pegar hardware de um servidor.
-}
getHardware : Server -> Hardware.Model
getHardware server =
    server.hardware


{-| Atualiza hardware de um servidor.
-}
setHardware : Hardware.Model -> Server -> Server
setHardware hardware server =
    { server | hardware = hardware }


{-| Tenta pegar notifications de um servidor.
-}
getNotifications : Server -> Notifications.Model
getNotifications =
    .notifications


{-| Atualiza notifications de um servidor.
-}
setNotifications : Notifications.Model -> Server -> Server
setNotifications notifications server =
    { server | notifications = notifications }


{-| Tenta pegar tunnels de um servidor.
-}
getTunnels : Server -> Tunnels.Model
getTunnels =
    .tunnels


{-| Atualiza tunnels de um servidor.
-}
setTunnels : Tunnels.Model -> Server -> Server
setTunnels tunnels server =
    { server | tunnels = tunnels }


{-| Retorna um ( CId, Server ) relacionado ao ( CId, Server ) e contexto
passado.
-}
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


{-| Retorna tipo do servidor.
-}
getType : Server -> ServerType
getType =
    .type_


{-| Tenta coletar nome (Label) do servidor.
-}
getLabel : CId -> Model -> Maybe String
getLabel cid model =
    case get cid model of
        Just server ->
            if isGateway server then
                Just <| getName server
            else
                Just <|
                    getName server
                        ++ " ("
                        ++ (Network.getIp <| getActiveNIP server)
                        ++ ")"

        Nothing ->
            Nothing


{-| Tenta coletar o Gateway de um Endpoint.
-}
getGatewayOfEndpoint : CId -> Model -> Maybe CId
getGatewayOfEndpoint cid model =
    case cid of
        GatewayCId _ ->
            Nothing

        EndpointCId nip ->
            model.gatewayOfEndpoints
                |> Dict.get nip
                |> Maybe.map GatewayCId
