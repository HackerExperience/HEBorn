module OS.SessionManager.WindowManager.Helpers exposing (windowData)

import Game.Data as Game
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
    in
        case context id model of
            Just EndpointContext ->
                window.endpoint
                    |> Maybe.andThen
                        (flip Game.fromServerIP game)
                    |> Maybe.withDefault data

            _ ->
                data
