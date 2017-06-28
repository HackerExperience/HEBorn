module OS.SessionManager.Dock.Update exposing (update)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Dock.Messages exposing (..)
import Apps.Apps as Apps
import Apps.Models as Apps
import OS.SessionManager.WindowManager.Models as WM


-- dock update is quite different, the dock is tightly integrated with
-- both the SessionManager and WindowManager, so it needs to access both


update :
    Msg
    -> Model
    -> Model
update msg model =
    Maybe.withDefault model (maybeUpdate msg model)



-- internals


maybeUpdate : Msg -> Model -> Maybe Model
maybeUpdate msg model =
    case msg of
        OpenApp app ->
            Maybe.map (openApp app model) (current model)

        CloseApps app ->
            Maybe.map (closeApps app model) (current model)

        RestoreApps app ->
            Maybe.map (restoreApps app model) (current model)

        MinimizeApps app ->
            Maybe.map (minimizeApps app model) (current model)

        CloseWindow ref ->
            Maybe.map (closeWindow ref model) (current model)

        RestoreWindow ref ->
            Maybe.map (restoreWindow ref model) (current model)

        MinimizeWindow ref ->
            Maybe.map (minimizeWindow ref model) (current model)

        FocusWindow ref ->
            Maybe.map (focusWindow ref model) (current model)


openApp : Apps.App -> Model -> WM.Model -> Model
openApp app model wm =
    refresh (WM.openWindow app wm) model


closeApps : Apps.App -> Model -> WM.Model -> Model
closeApps app model wm =
    refresh (WM.closeAppWindows app wm) model


restoreApps : Apps.App -> Model -> WM.Model -> Model
restoreApps app model wm =
    refresh (WM.restoreAppWindows app wm) model


minimizeApps : Apps.App -> Model -> WM.Model -> Model
minimizeApps app model wm =
    refresh (WM.minimizeAppWindows app wm) model


closeWindow : WindowRef -> Model -> WM.Model -> Model
closeWindow ( _, id ) model wm =
    refresh (WM.closeWindow id wm) model


restoreWindow : WindowRef -> Model -> WM.Model -> Model
restoreWindow ( _, id ) model wm =
    refresh (WM.restoreWindow id wm) model


minimizeWindow : WindowRef -> Model -> WM.Model -> Model
minimizeWindow ( _, id ) model wm =
    refresh (WM.minimizeWindow id wm) model


focusWindow : WindowRef -> Model -> WM.Model -> Model
focusWindow ( _, id ) model wm =
    refresh (WM.focusWindow id wm) model
