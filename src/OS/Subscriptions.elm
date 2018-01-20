module OS.Subscriptions exposing (subscriptions)

import OS.Config exposing (..)
import OS.Models exposing (..)
import OS.Messages exposing (..)
import Game.Data as Game
import OS.SessionManager.Models as SessionManager
import OS.SessionManager.Subscriptions as SessionManager


subscriptions : Config msg -> Game.Data -> Model -> Sub msg
subscriptions config data model =
    session config data model.session



-- internals


session : Config msg -> Game.Data -> SessionManager.Model -> Sub msg
session config data model =
    let
        config_ =
            smConfig config
    in
        model
            |> SessionManager.subscriptions config_ data
