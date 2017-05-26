module OS.SessionManager.Subscriptions exposing (..)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Models as WindowManager
import OS.SessionManager.WindowManager.Subscriptions as WindowManager
import Game.Models exposing (GameModel)


-- TODO: this needs to change to add pinned window support


subscriptions : GameModel -> Model -> Sub Msg
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


windowManager : GameModel -> WindowManager.Model -> Sub Msg
windowManager game model =
    model
        |> WindowManager.subscriptions game
        |> Sub.map WindowManagerMsg


defaultNone : Maybe (Sub Msg) -> Sub Msg
defaultNone =
    Maybe.withDefault Sub.none
