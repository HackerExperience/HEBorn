module OS.Subscriptions exposing (subscriptions)

import OS.Config exposing (..)
import OS.Models exposing (..)
import OS.Messages exposing (..)
import OS.SessionManager.Models as SessionManager
import OS.SessionManager.Subscriptions as SessionManager


subscriptions : Config msg -> Model -> Sub msg
subscriptions config model =
    session config model.session



-- internals


session : Config msg -> SessionManager.Model -> Sub msg
session config model =
    let
        config_ =
            smConfig config
    in
        model
            |> SessionManager.subscriptions config_
