module Game.Servers.Tunnels.Models exposing (..)

{-| Documentação pendente pois este domínio está incompleto e provavelmente
errado.
-}

import Dict exposing (Dict)
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Network as Network


type alias Model =
    Dict ID Tunnel


type alias ID =
    ( Bounces.ID, Network.ID, Network.IP )


type alias Tunnel =
    { connections : Connections
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


newTunnel : Tunnel
newTunnel =
    { connections = Dict.empty }


newConnection : String -> Connection
newConnection string =
    { type_ = toConnectionType string }


toTunnelID : Maybe Bounces.ID -> String -> ID
toTunnelID bounce endpoint =
    let
        bounce_ =
            Maybe.withDefault "" bounce

        ( network, ip ) =
            Network.fromString endpoint
    in
        ( bounce_, network, ip )


getTunnel : ID -> Model -> Tunnel
getTunnel id model =
    Dict.get id model
        |> Maybe.withDefault newTunnel


getConnection : ConnectionID -> Tunnel -> Maybe Connection
getConnection id { connections } =
    Dict.get id connections


insertConnection : ConnectionID -> Connection -> Tunnel -> Tunnel
insertConnection id conn ({ connections } as tunnel) =
    let
        connections_ =
            Dict.insert id conn connections

        tunnel_ =
            { tunnel | connections = connections_ }
    in
        tunnel_


insertTunnel : ID -> Tunnel -> Model -> Model
insertTunnel =
    Dict.insert


toConnectionType : String -> ConnectionType
toConnectionType str =
    case str of
        "ftp" ->
            ConnectionFTP

        "ssh" ->
            ConnectionSSH

        _ ->
            ConnectionUnknown
