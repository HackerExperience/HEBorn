module OS.SessionManager.Subscriptions exposing (..)

import OS.SessionManager.Config exposing (..)
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.WindowManager.Models as WindowManager
import OS.SessionManager.WindowManager.Subscriptions as WindowManager
import Game.Servers.Models as Servers


-- TODO: this needs to change to add pinned window support


subscriptions : Config msg -> Model -> Sub msg
subscriptions config model =
    let
        id =
            config.activeServer
                |> Tuple.first
                |> Servers.toSessionId

        windowManagerSub =
            model
                |> get id
                |> Maybe.map (windowManager config id)
                |> defaultNone
    in
        Sub.batch [ windowManagerSub ]



-- internals


windowManager : Config msg -> ID -> WindowManager.Model -> Sub msg
windowManager config id model =
    let
        config_ =
            wmConfig id config
    in
        WindowManager.subscriptions config_ model


defaultNone : Maybe (Sub msg) -> Sub msg
defaultNone =
    Maybe.withDefault Sub.none
