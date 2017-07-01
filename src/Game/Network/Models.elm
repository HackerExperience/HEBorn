module Game.Network.Models
    exposing
        ( Model
        , Bounces
        , BounceID
        , Bounce
        , IP
        , Tunnels
        , TunnelID
        , Tunnel
        , Connections
        , ConnectionID
        , Connection
        , ConnectionType(..)
        , initialModel
        , getBounces
        , getTunnels
        , getConnections
        , newTunnel
        , getBounce
        , setBounce
        , getTunnel
        , setTunnel
        , getActiveTunnel
        , setActiveTunnel
        , insertTunnel
        , removeTunnel
        , getGateway
        , setGateway
        , getEndpoint
        , setEndpoint
        , insertConnection
        , removeConnection
        )

import Dict exposing (Dict)


type alias Model =
    { bounces : Bounces
    , tunnels : Tunnels
    , active : Maybe TunnelID
    }


type alias Bounces =
    Dict BounceID Bounce


type alias BounceID =
    String


type alias Bounce =
    { name : String
    , chain : List IP
    }


type alias IP =
    String


type alias Tunnels =
    Dict TunnelID Tunnel


type alias TunnelID =
    String


type alias Tunnel =
    { gateway : IP
    , endpoint : IP
    , bounce : Maybe BounceID
    , connections : Connections
    }


type alias Connections =
    Dict ConnectionID Connection


type alias ConnectionID =
    String


type alias Connection =
    -- this may receive more data as we integrate things
    { type_ : ConnectionType }


type ConnectionType
    = ConnectionFTP
    | ConnectionSSH
    | ConnectionX11
    | ConnectionUnknown



-- this structure is an atempt to reduce boilerplate by using lenses,
-- it may or not help with future model changes, basically a localized
-- proof of concept


initialModel : Model
initialModel =
    { active = Nothing
    , bounces = Dict.empty
    , tunnels = Dict.empty
    }



-- fetch indexes (useful for list views)


getBounces : Model -> Bounces
getBounces =
    .bounces


getTunnels : Model -> Tunnels
getTunnels =
    .tunnels


getConnections : Model -> Maybe Connections
getConnections model =
    case getTunnel model of
        Just tunnel ->
            Just tunnel.connections

        Nothing ->
            Nothing



-- insert / remove / update entries


newTunnel : IP -> IP -> Model -> Tunnel
newTunnel gateway endpoint model =
    case getTunnel model of
        Just tunnel ->
            { gateway = gateway
            , endpoint = endpoint
            , bounce = tunnel.bounce
            , connections = Dict.empty
            }

        Nothing ->
            { gateway = gateway
            , endpoint = endpoint
            , bounce = Nothing
            , connections = Dict.empty
            }


getBounce : String -> Model -> Maybe Bounce
getBounce id =
    .bounces >> Dict.get id


setBounce : String -> Maybe Bounce -> Model -> Model
setBounce id item model =
    model.bounces
        |> setDict id item
        |> flip setBouncesOfModel model


getTunnel : Model -> Maybe Tunnel
getTunnel ({ active } as model) =
    case active of
        Just id ->
            Dict.get id model.tunnels

        Nothing ->
            Nothing


setTunnel : Maybe Tunnel -> Model -> Model
setTunnel tunnel ({ active } as model) =
    case active of
        Just id ->
            model.tunnels
                |> setDict id tunnel
                |> flip setTunnelsOfModel model

        Nothing ->
            model


getActiveTunnel : Model -> Maybe TunnelID
getActiveTunnel =
    .active


setActiveTunnel : Maybe TunnelID -> Model -> Model
setActiveTunnel a m =
    { m | active = a }


insertTunnel : TunnelID -> Tunnel -> Model -> Model
insertTunnel id tunnel model =
    model.tunnels
        |> Dict.insert id tunnel
        |> flip setTunnelsOfModel model


removeTunnel : TunnelID -> Model -> Model
removeTunnel id m =
    m.tunnels
        |> Dict.remove id
        |> flip setTunnelsOfModel m


getGateway : Model -> Maybe IP
getGateway model =
    model
        |> getTunnel
        |> Maybe.map .gateway


setGateway : IP -> Model -> Model
setGateway ip model =
    let
        tunnel =
            getTunnel model

        maybeTunnel =
            Maybe.map (setGatewayOfTunnel ip) tunnel

        model_ =
            setTunnel maybeTunnel model
    in
        model_


getEndpoint : Model -> Maybe IP
getEndpoint model =
    model
        |> getTunnel
        |> Maybe.map .endpoint


setEndpoint : IP -> Model -> Model
setEndpoint ip model =
    let
        tunnel =
            getTunnel model

        maybeTunnel =
            Maybe.map (setEndpointOfTunnel ip) tunnel

        model_ =
            setTunnel maybeTunnel model
    in
        model_


insertConnection : ConnectionID -> Connection -> Model -> Model
insertConnection id connection model =
    let
        setter tunnel =
            tunnel.connections
                |> Dict.insert id connection
                |> flip setConnectionOfTunnel tunnel

        model_ =
            model
                |> getTunnel
                |> Maybe.map setter
                |> flip setTunnel model
    in
        model_


removeConnection : ConnectionID -> Model -> Model
removeConnection id model =
    let
        setter tunnel =
            tunnel.connections
                |> Dict.remove id
                |> flip setConnectionOfTunnel tunnel

        model_ =
            model
                |> getTunnel
                |> Maybe.map setter
                |> flip setTunnel model
    in
        model_



-- internals


setBouncesOfModel : Bounces -> Model -> Model
setBouncesOfModel b m =
    { m | bounces = b }


setTunnelsOfModel : Tunnels -> Model -> Model
setTunnelsOfModel t m =
    { m | tunnels = t }


setGatewayOfTunnel : IP -> Tunnel -> Tunnel
setGatewayOfTunnel g m =
    { m | gateway = g }


setEndpointOfTunnel : IP -> Tunnel -> Tunnel
setEndpointOfTunnel g m =
    { m | endpoint = g }


setBounceOfTunnel : Maybe BounceID -> Tunnel -> Tunnel
setBounceOfTunnel g m =
    { m | bounce = g }


setConnectionOfTunnel : Connections -> Tunnel -> Tunnel
setConnectionOfTunnel c m =
    { m | connections = c }



-- TODO : move this to DictUtils.setter if this format gets approved


setDict : comparable -> Maybe b -> Dict comparable b -> Dict comparable b
setDict id b =
    case b of
        Just b ->
            Dict.insert id b

        Nothing ->
            Dict.remove id
