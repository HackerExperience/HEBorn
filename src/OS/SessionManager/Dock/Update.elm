module OS.SessionManager.Dock.Update exposing (update)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Dock.Messages exposing (..)
import Game.Data as GameData
import OS.SessionManager.WindowManager.Models as WM


-- dock update is quite different, the dock is tightly integrated with
-- both the SessionManager and WindowManager, so it needs to access both


update :
    GameData.Data
    -> Msg
    -> Model
    -> Model
update data msg model =
    case get data.id model of
        Just wm ->
            refresh data.id (updateModel msg wm) model

        Nothing ->
            model



-- internals


updateModel : Msg -> WM.Model -> WM.Model
updateModel msg wm =
    case msg of
        OpenApp app ->
            WM.openWindow app wm

        CloseApps app ->
            WM.closeAppWindows app wm

        RestoreApps app ->
            WM.restoreAppWindows app wm

        MinimizeApps app ->
            WM.minimizeAppWindows app wm

        CloseWindow ( _, id ) ->
            WM.closeWindow id wm

        RestoreWindow ( _, id ) ->
            WM.restoreWindow id wm

        MinimizeWindow ( _, id ) ->
            WM.minimizeWindow id wm

        FocusWindow ( _, id ) ->
            WM.focusWindow id wm
