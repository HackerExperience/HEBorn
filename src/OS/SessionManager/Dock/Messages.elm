module OS.SessionManager.Dock.Messages exposing (Msg(..))

import Apps.Apps exposing (App)
import OS.SessionManager.WindowManager.Models as WM


type Msg
    = OpenApp App
    | MinimizeApps App
    | RestoreApps App
    | CloseApps App
    | MinimizeWindow WM.ID
    | FocusWindow WM.ID
    | RestoreWindow WM.ID
    | CloseWindow WM.ID
