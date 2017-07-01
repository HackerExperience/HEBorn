module OS.SessionManager.Subscriptions exposing (..)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Models as WindowManager
import OS.SessionManager.WindowManager.Subscriptions as WindowManager
import Game.Models as Game
import Game.Data as GameData


-- TODO: this needs to change to add pinned window support


subscriptions : Game.Model -> Model -> Sub Msg
subscriptions game model =
    let
        windowManagerSub =
            model
                |> current
                |> Maybe.map (windowManager game)
                |> defaultNone
    in
        Sub.batch [ windowManagerSub ]



-- internals


windowManager : Game.Model -> WindowManager.Model -> Sub Msg
windowManager game model =
    case GameData.fromGame game of
        Just data ->
            model
                |> WindowManager.subscriptions data
                |> Sub.map WindowManagerMsg

        Nothing ->
            Sub.none


defaultNone : Maybe (Sub Msg) -> Sub Msg
defaultNone =
    Maybe.withDefault Sub.none
