module OS.SessionManager.Dock.Messages exposing (Msg(..))

import Apps.Apps exposing (App)
import OS.SessionManager.WindowManager.Models as WM


type Msg
    = AppButton App
    | OpenApp App
    | MinimizeApps App
    | CloseApps App
    | MinimizeWindow WM.ID
    | FocusWindow WM.ID
    | RestoreWindow WM.ID
    | CloseWindow WM.ID
