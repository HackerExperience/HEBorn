module OS.SessionManager.Dock.Update exposing (update)

import Dict
import Game.Data as Game
import Game.Servers.Models as Servers
import OS.SessionManager.Dock.Messages exposing (..)
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.WindowManager.Models as WM


update :
    Game.Data
    -> Msg
    -> Model
    -> Model
update data msg model =
    case msg of
        OpenApp app ->
            let
                ip =
                    data
                        |> Game.getServer
                        |> Servers.getEndpoint

                model_ =
                    openApp data.id ip app model
            in
                model_

        RestoreApps app ->
            -- WM.restoreAll app wm
            model

        _ ->
            mapWM (wmUpdate msg) data model



-- internals


mapWM : (WM.Model -> WM.Model) -> Game.Data -> Model -> Model
mapWM func data ({ sessions } as model) =
    case Dict.get data.id sessions of
        Just wm ->
            let
                sessions_ =
                    Dict.insert data.id (func wm) model.sessions

                model_ =
                    { model | sessions = sessions_ }
            in
                model_

        Nothing ->
            model


wmUpdate : Msg -> WM.Model -> WM.Model
wmUpdate msg wm =
    case msg of
        CloseApps app ->
            WM.removeAll app wm

        MinimizeApps app ->
            WM.minimizeAll app wm

        CloseWindow id ->
            WM.remove id wm

        RestoreWindow id ->
            WM.restore id wm

        MinimizeWindow id ->
            WM.minimize id wm

        FocusWindow id ->
            WM.focus id wm

        _ ->
            wm
