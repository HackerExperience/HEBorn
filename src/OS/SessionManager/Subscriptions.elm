module OS.SessionManager.Subscriptions exposing (..)

import Core.Error as Error
import OS.SessionManager.Config exposing (..)
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Helpers exposing (..)
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.WindowManager.Models as WindowManager
import OS.SessionManager.WindowManager.Subscriptions as WindowManager
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Models as Servers


-- TODO: this needs to change to add pinned window support


subscriptions : Config msg -> Model -> Sub msg
subscriptions config model =
    let
        id =
            case config.activeContext of
                Gateway ->
                    config.activeServer
                        |> Tuple.first
                        |> Servers.toSessionId

                Endpoint ->
                    let
                        endpointSessionId =
                            config.activeServer
                                |> Tuple.second
                                |> Servers.getEndpointCId
                                |> Maybe.map Servers.toSessionId
                    in
                        case endpointSessionId of
                            Just endpointSessionId ->
                                endpointSessionId

                            Nothing ->
                                "U = {x}, ∄ x ⊂ U"
                                    |> Error.neeiae
                                    |> uncurry Native.Panic.crash

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
