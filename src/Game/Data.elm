module Game.Data
    exposing
        ( Data
        , getID
        , getServer
        , getGame
        , fromGateway
        , fromEndpoint
        , fromActiveServer
        , fromServerID
        )

import Game.Models exposing (..)
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers


type alias Data =
    { id : Servers.ID
    , server : Servers.Server
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
        |> Maybe.map (fromServer model)


fromEndpoint : Model -> Maybe Data
fromEndpoint model =
    model
        |> getEndpoint
        |> Maybe.map (fromServer model)


fromActiveServer : Model -> Maybe Data
fromActiveServer model =
    model
        |> getActiveServer
        |> Maybe.map (fromServer model)


fromServerID : Servers.ID -> Model -> Maybe Data
fromServerID id model =
    let
        servers =
            getServers model
    in
        case Servers.get id servers of
            Just server ->
                Just <| fromServer model ( id, server )

            Nothing ->
                Nothing



-- internals


fromServer : Model -> ( Servers.ID, Servers.Server ) -> Data
fromServer model ( id, server ) =
    { id = id
    , server = server
    , game = model
    }
