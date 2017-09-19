module OS.SessionManager.Helpers exposing (toSessionID)

import Game.Data as Game
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
    in
        case Account.getContext <| Game.getAccount game of
            Gateway ->
                data.id

            Endpoint ->
                data
                    |> Game.getServer
                    |> Servers.getEndpoint
                    |> Maybe.withDefault data.id
