module Game.Data
    exposing
        ( Data
        , getIP
        , getID
        , getContext
        , getGame
        , fromGame
        )

import Game.Models exposing (..)
import Game.Meta.Models as Meta
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Network.Models as Network


type alias Data =
    { id : Servers.ID
    , server : Servers.Server
    , game : Model
    }


getServer : Data -> Servers.Server
getServer =
    .server


getID : Data -> Servers.ID
getID =
    .id


getIP : Data -> Network.IP
getIP =
    getServer >> Servers.getIP


getContext : Data -> Meta.Context
getContext =
    getGame >> getMeta >> Meta.getContext


getGame : Data -> Model
getGame =
    .game


fromGame : Model -> Maybe Data
fromGame model =
    let
        meta =
            getMeta model

        network =
            getNetwork model

        servers =
            getServers model

        maybeID =
            case Meta.getContext meta of
                Meta.Gateway ->
                    Meta.getGateway meta

                Meta.Endpoint ->
                    network
                        |> Network.getEndpoint
                        |> Maybe.andThen (flip Servers.mapNetwork servers)

        maybeServer =
            case maybeID of
                Just id ->
                    case Servers.get id servers of
                        Just server ->
                            Just ( server, id )

                        Nothing ->
                            Nothing

                Nothing ->
                    Nothing
    in
        case maybeServer of
            Just ( server, id ) ->
                Just
                    { id = id
                    , server = server
                    , game = model
                    }

            Nothing ->
                Nothing
