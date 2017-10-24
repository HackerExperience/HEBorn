module OS.SessionManager.Helpers exposing (toSessionID)

import Native.Panic
import Game.Data exposing (Data)
import Game.Models as Game
import Game.Meta.Types exposing (..)
import Game.Account.Models as Account
import Game.Models as Game
import Game.Servers.Models as Servers
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Types exposing (..)


toSessionID : Data -> ID
toSessionID ({ game } as data) =
    let
        activeContext =
            game
                |> Game.getAccount
                |> Account.getContext

        activeServer =
            Game.Data.getActiveServer data

        servers =
            Game.getServers game
    in
        case activeContext of
            Gateway ->
                data
                    |> Game.Data.getActiveCId
                    |> Servers.toSessionId

            Endpoint ->
                let
                    endpointSessionId =
                        activeServer
                            |> Servers.getEndpointCId
                            |> Maybe.map Servers.toSessionId
                in
                    case endpointSessionId of
                        Just endpointSessionId ->
                            endpointSessionId

                        Nothing ->
                            Native.Panic.crash
                                "ERROR_NONEXISTINGENDPOINT_ISACTIVEENDPOINT"
                                "U = {x}, ∄ x ⊂ U"
