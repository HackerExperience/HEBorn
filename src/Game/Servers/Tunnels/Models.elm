module Game.Servers.Tunnels.Models
    exposing
        ( Model
        , ID
        , Tunnel
        , Connections
        , ConnectionID
        , Connection
        , ConnectionType(..)
        , initialModel
        , get
        , insert
        , remove
        , getConnections
        , setConnections
        , insertConnection
        , removeConnection
        )

import Dict exposing (Dict)
import Game.Account.Bounces.Models as Bounces
import Game.Network.Types exposing (NIP)


type alias Model =
    Dict ID Tunnel


type alias ID =
    ( Bounces.ID, NIP )


type alias Tunnel =
    { active : Bool
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


initialModel : Model
initialModel =
    Dict.empty



-- tunnel crud


get : Maybe Bounces.ID -> NIP -> Model -> Tunnel
get bounce endpoint model =
    model
        |> Dict.get (toTunnelID bounce endpoint)
        |> Maybe.withDefault { active = True, connections = Dict.empty }


insert : Maybe Bounces.ID -> NIP -> Tunnel -> Model -> Model
insert bounce endpoint tunnel model =
    Dict.insert (toTunnelID bounce endpoint) tunnel model


remove : Maybe Bounces.ID -> NIP -> Model -> Model
remove bounce endpoint model =
    Dict.remove (toTunnelID bounce endpoint) model



-- tunnel getters/setters


getConnections : Tunnel -> Connections
getConnections =
    .connections


setConnections : Connections -> Tunnel -> Tunnel
setConnections connections tunnel =
    { tunnel | connections = connections }



-- connection crud


insertConnection :
    Maybe Bounces.ID
    -> NIP
    -> ConnectionID
    -> Connection
    -> Model
    -> Model
insertConnection bounce endpoint id connection model =
    let
        tunnel =
            get bounce endpoint model

        { connections } =
            tunnel

        connections_ =
            Dict.insert id connection connections

        tunnel_ =
            { tunnel | connections = connections_ }

        model_ =
            Dict.insert (toTunnelID bounce endpoint) tunnel_ model
    in
        model_


removeConnection :
    Maybe Bounces.ID
    -> NIP
    -> ConnectionID
    -> Model
    -> Model
removeConnection bounce endpoint id model =
    let
        tunnel =
            get bounce endpoint model

        { connections } =
            tunnel

        connections_ =
            Dict.remove id connections

        tunnel_ =
            { tunnel | connections = connections_ }

        model_ =
            Dict.insert (toTunnelID bounce endpoint) tunnel_ model
    in
        model_



-- internals


toTunnelID : Maybe Bounces.ID -> NIP -> ID
toTunnelID bounce endpoint =
    let
        bounce_ =
            Maybe.withDefault "" bounce
    in
        ( bounce_, endpoint )
