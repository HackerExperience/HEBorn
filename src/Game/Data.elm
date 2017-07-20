module Game.Data
    exposing
        ( Data
        , getID
        , getServer
        , getGame
        , fromGateway
        , fromEndpoint
        , fromServerID
        )

import Game.Models exposing (..)
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers


type alias Data =
    { id : Servers.ID
    , server : Servers.Server
    , online : Bool
    , game : Model
    }


getID : Data -> Servers.ID
getID =
    .id


getServer : Data -> Servers.Server
getServer =
    .server


getGame : Data -> Model
getGame =
    .game


fromGateway : Model -> Maybe Data
fromGateway model =
    model
        |> getGateway
        |> Maybe.map (fromServer True model)


fromEndpoint : Model -> Maybe Data
fromEndpoint model =
    model
        |> getEndpoint
        |> Maybe.map (fromServer True model)


fromServerID : Servers.ID -> Model -> Maybe Data
fromServerID id model =
    let
        servers =
            getServers model

        ( gatewayID, gateway ) =
            model
                |> getGateway
                |> Maybe.map (\( left, right ) -> ( Just left, Just right ))
                |> Maybe.withDefault ( Nothing, Nothing )

        endpointID =
            gateway
                |> Maybe.andThen Servers.getEndpoint
                |> Maybe.andThen (flip Servers.mapNetwork servers)

        maybeID =
            Just id

        online =
            maybeID == gatewayID || maybeID == endpointID
    in
        case Servers.get id servers of
            Just server ->
                Just <| fromServer online model ( id, server )

            Nothing ->
                Nothing



-- internals


fromServer : Bool -> Model -> ( Servers.ID, Servers.Server ) -> Data
fromServer online model ( id, server ) =
    { id = id
    , server = server
    , online = online
    , game = model
    }
