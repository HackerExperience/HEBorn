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
import Game.Servers.Tunnels.Models as Tunnels


type alias Data =
    { id : Servers.ID
    , server : Servers.Server
    , game : Model
    }


getServer : Data -> Servers.Server
getServer =
    .server


getIP : Data -> Tunnels.IP
getIP =
    getServer >> Servers.getIP


getID : Data -> Servers.ID
getID =
    .id


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

        servers =
            getServers model

        maybeServerID =
            getServerID model

        maybeServer =
            Maybe.andThen (flip Servers.get servers) maybeServerID
    in
        case ( maybeServer, maybeServerID ) of
            ( Just server, Just id ) ->
                Just
                    { id = id
                    , server = server
                    , game = model
                    }

            _ ->
                Nothing
