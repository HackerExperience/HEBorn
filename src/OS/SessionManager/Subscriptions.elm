module OS.SessionManager.Subscriptions exposing (..)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Helpers exposing (..)
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.WindowManager.Models as WindowManager
import OS.SessionManager.WindowManager.Subscriptions as WindowManager
import Game.Data as Game


-- TODO: this needs to change to add pinned window support


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    let
        id =
            toSessionID data

        windowManagerSub =
            model
                |> get id
                |> Maybe.map (windowManager data id)
                |> defaultNone
    in
        Sub.batch [ windowManagerSub ]



-- internals


windowManager : Game.Data -> ID -> WindowManager.Model -> Sub Msg
windowManager data id model =
    model
        |> WindowManager.subscriptions data
        |> Sub.map (WindowManagerMsg id)


defaultNone : Maybe (Sub Msg) -> Sub Msg
defaultNone =
    Maybe.withDefault Sub.none
