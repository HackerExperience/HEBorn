module Game.Data
    exposing
        ( Data
        , getActiveCId
        , getActiveServer
        , getGame
        , getEndpoints
        , usanfeFromGateway
        , fromGateway
        , fromEndpoint
        , fromServerCId
        )

import Game.Models exposing (..)
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers


type alias Data =
    { server : ( Servers.CId, Servers.Server )
    , online : Bool
    , game : Model
    }



-- Getters


getActiveCId : Data -> Servers.CId
getActiveCId =
    .server >> Tuple.first


getActiveServer : Data -> Servers.Server
getActiveServer =
    .server >> Tuple.second


getGame : Data -> Model
getGame =
    .game



-- Initializers


fromGateway : Model -> Maybe Data
fromGateway model =
    model
        |> getGateway
        |> Maybe.map (fromServer True model)


usanfeFromGateway : Model -> Data
usanfeFromGateway model =
    model
        |> unsafeGetGateway
        |> fromServer True model


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



-- Helpers


getEndpoints : Data -> List Servers.CId
getEndpoints =
    getActiveServer
        >> Servers.getEndpoints
        >> Maybe.withDefault []



-- Internals


fromServer : Bool -> Model -> ( Servers.CId, Servers.Server ) -> Data
fromServer online model server =
    { server = server
    , online = online
    , game = model
    }
