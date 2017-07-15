module OS.SessionManager.WindowManager.Helpers exposing (windowData)

import Game.Data as Game
import Game.Models as Game
import Game.Servers.Models as Servers
import OS.SessionManager.WindowManager.Context exposing (..)
import OS.SessionManager.WindowManager.Models exposing (..)


windowData :
    Game.Data
    -> ID
    -> Window
    -> Model
    -> Game.Data
windowData data id window model =
    let
        game =
            Game.getGame data

        servers =
            Game.getServers game
    in
        case context id model of
            Just GatewayContext ->
                game
                    |> Game.fromGateway
                    |> Maybe.withDefault data

            Just EndpointContext ->
                window.endpoint
                    |> Maybe.andThen (flip Servers.mapNetwork servers)
                    |> Maybe.andThen (flip Game.fromServerID game)
                    |> Maybe.withDefault data

            Just NoContext ->
                data

            Nothing ->
                data
