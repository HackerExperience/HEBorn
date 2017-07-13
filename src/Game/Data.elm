module Game.Data
    exposing
        ( Data
        , getID
        , getServer
        , getGame
        , fromGateway
        , fromEndpoint
        , fromServerID
        , fromServerIP
        )

import Game.Models exposing (..)
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Network.Types exposing (IP)


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
        |> getActiveServerID
        |> Maybe.andThen (flip fromServerID model)


fromEndpoint : Model -> Maybe Data
fromEndpoint model =
    let
        servers =
            getServers model

        maybeGateway =
            getActiveServer model
    in
        maybeGateway
            |> Maybe.andThen Servers.getEndpoint
            |> Maybe.andThen (flip Servers.mapNetwork servers)
            |> Maybe.andThen (flip fromServerID model)


fromServerID : Servers.ID -> Model -> Maybe Data
fromServerID id model =
    case Servers.get id (getServers model) of
        Just server ->
            Just
                { id = id
                , server = server
                , game = model
                }

        _ ->
            Nothing


fromServerIP : IP -> Model -> Maybe Data
fromServerIP ip model =
    case Servers.mapNetwork ip (getServers model) of
        Just id ->
            fromServerID id model

        Nothing ->
            Nothing
