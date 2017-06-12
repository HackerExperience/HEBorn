module OS.SessionManager.Dock.Messages exposing (Msg(..))

import Apps.Models exposing (App)
import OS.SessionManager.WindowManager.Models exposing (WindowID)


type Msg
    = OpenApp App
    | MinimizeApps App
    | RestoreApps App
    | CloseApps App
    | MinimizeWindow ( String, WindowID )
    | FocusWindow ( String, WindowID )
    | RestoreWindow ( String, WindowID )
    | CloseWindow ( String, WindowID )
