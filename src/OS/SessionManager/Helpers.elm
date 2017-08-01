module OS.SessionManager.Helpers exposing (toSessionID)

import Game.Data as Game
import Game.Meta.Types as Meta
import Game.Meta.Models as Meta
import Game.Models as Game
import Game.Servers.Models as Servers
import OS.SessionManager.Models exposing (..)


toSessionID : Game.Data -> ID
toSessionID data =
    let
        game =
            Game.getGame data
    in
        case Meta.getContext <| Game.getMeta game of
            Meta.Gateway ->
                data.id

            Meta.Endpoint ->
                data
                    |> Game.getServer
                    |> Servers.getEndpoint
                    |> Maybe.andThen
                        (flip Servers.mapNetwork <| Game.getServers game)
                    |> Maybe.withDefault data.id
