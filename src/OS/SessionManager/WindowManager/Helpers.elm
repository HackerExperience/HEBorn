module OS.SessionManager.WindowManager.Helpers exposing (..)

import Game.Data as Game
import Game.Models as Game
import OS.SessionManager.WindowManager.Config exposing (..)
import OS.SessionManager.WindowManager.Models exposing (Window, Model, ID, windowContext)
import Game.Meta.Types.Context exposing (..)


--CONFREFACT Kill all of this after refactor


windowData :
    Config msg
    -> Game.Data
    -> Maybe Context
    -> ID
    -> Window
    -> Model
    -> Game.Data
windowData config data maybeContext id window model =
    let
        game =
            Game.getGame data

        servers =
            Game.getServers game

        context =
            Maybe.withDefault (windowContext window) maybeContext
    in
        case context of
            Gateway ->
                game
                    |> Game.fromGateway
                    |> Maybe.withDefault data

            Endpoint ->
                window.endpoint
                    |> Maybe.andThen (flip Game.fromServerCId game)
                    |> Maybe.withDefault data
