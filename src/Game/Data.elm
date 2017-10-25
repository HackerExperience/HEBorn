module Game.Data
    exposing
        ( Data
        , getActiveCId
        , getActiveServer
        , getGame
        , getEndpoints
        , fromGateway
        , fromEndpoint
        , fromServerCId
        )

import Game.Models exposing (..)
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers


type alias Data =
    { activeCId : Servers.CId
    , server : Servers.Server
    , online : Bool
    , game : Model
    }


getActiveCId : Data -> Servers.CId
getActiveCId =
    .activeCId


getActiveServer : Data -> Servers.Server
getActiveServer =
    .server


getGame : Data -> Model
getGame =
    .game


fromGateway : Model -> Maybe Data
fromGateway model =
    model
        |> getGateway
        |> Maybe.map (fromServer True model)


getEndpoints : Data -> List Servers.CId
getEndpoints =
    .server
        >> Servers.getEndpoints
        >> Maybe.withDefault []


fromEndpoint : Model -> Maybe Data
fromEndpoint model =
    model
        |> getEndpoint
        |> Maybe.map (fromServer True model)


fromServerCId : Servers.CId -> Model -> Maybe Data
fromServerCId cid model =
    let
        servers =
            getServers model

        ( gatewayId, gateway ) =
            model
                |> getGateway
                |> Maybe.map (\( left, right ) -> ( Just left, Just right ))
                |> Maybe.withDefault ( Nothing, Nothing )

        endpointId =
            Maybe.andThen Servers.getEndpointCId gateway

        maybeCid =
            Just cid

        online =
            maybeCid == gatewayId || maybeCid == endpointId
    in
        case Servers.get cid servers of
            Just server ->
                Just <| fromServer online model ( cid, server )

            Nothing ->
                Nothing



-- internals


fromServer : Bool -> Model -> ( Servers.CId, Servers.Server ) -> Data
fromServer online model ( cid, server ) =
    { activeCId = cid
    , server = server
    , online = online
    , game = model
    }
