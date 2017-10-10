module OS.SessionManager.Helpers exposing (toSessionID)

import Game.Data as Game
import Game.Models as Game
import Game.Meta.Types exposing (..)
import Game.Account.Models as Account
import Game.Models as Game
import Game.Servers.Models as Servers
import OS.SessionManager.Models exposing (..)


toSessionID : Game.Data -> ID
toSessionID data =
    let
        game =
            Game.getGame data

        context =
            game
                |> Game.getAccount
                |> Account.getContext

        server =
            Game.getServer data

        servers =
            Game.getServers game
    in
        case context of
            Gateway ->
                Servers.toSessionId data.id servers

            Endpoint ->
                let
                    endpointSessionId =
                        server
                            |> Servers.getEndpoint
                            |> Maybe.map (flip Servers.toSessionId servers)
                in
                    case endpointSessionId of
                        Just endpointSessionId ->
                            endpointSessionId

                        Nothing ->
                            Servers.toSessionId data.id servers
