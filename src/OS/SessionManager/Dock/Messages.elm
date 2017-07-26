module OS.SessionManager.Dock.Messages exposing (Msg(..))

import Apps.Apps exposing (App)


type alias WindowID =
    -- WM.ID creates a ciclic reference
    String


type Msg
    = AppButton App
    | OpenApp App
    | MinimizeApps App
    | CloseApps App
    | MinimizeWindow WindowID
    | FocusWindow WindowID
    | RestoreWindow WindowID
    | CloseWindow WindowID
