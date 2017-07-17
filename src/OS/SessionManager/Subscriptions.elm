module OS.SessionManager.Subscriptions exposing (..)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Helpers exposing (..)
import OS.SessionManager.WindowManager.Models as WindowManager
import OS.SessionManager.WindowManager.Subscriptions as WindowManager
import Game.Data as GameData


-- TODO: this needs to change to add pinned window support


subscriptions : GameData.Data -> Model -> Sub Msg
subscriptions data model =
    let
        id =
            toSessionID data

        windowManagerSub =
            model
                |> get id
                |> Maybe.map (windowManager data)
                |> defaultNone
    in
        Sub.batch [ windowManagerSub ]



-- internals


windowManager : GameData.Data -> WindowManager.Model -> Sub Msg
windowManager data model =
    model
        |> WindowManager.subscriptions data
        |> Sub.map WindowManagerMsg


defaultNone : Maybe (Sub Msg) -> Sub Msg
defaultNone =
    Maybe.withDefault Sub.none
