module OS.SessionManager.Subscriptions exposing (..)

import OS.SessionManager.Config exposing (..)
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Helpers exposing (..)
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.WindowManager.Models as WindowManager
import OS.SessionManager.WindowManager.Subscriptions as WindowManager
import Game.Data as Game


-- TODO: this needs to change to add pinned window support


subscriptions : Config msg -> Game.Data -> Model -> Sub msg
subscriptions config data model =
    let
        id =
            toSessionID data

        windowManagerSub =
            model
                |> get id
                |> Maybe.map (windowManager config data id)
                |> defaultNone
    in
        Sub.batch [ windowManagerSub ]



-- internals


windowManager : Config msg -> Game.Data -> ID -> WindowManager.Model -> Sub msg
windowManager config data id model =
    let
        config_ =
            wmConfig id config
    in
        model
            |> WindowManager.subscriptions config_ data


defaultNone : Maybe (Sub msg) -> Sub msg
defaultNone =
    Maybe.withDefault Sub.none
