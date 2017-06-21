module OS.SessionManager.Messages exposing (Msg(..))

import OS.SessionManager.WindowManager.Messages as WindowManager
import OS.SessionManager.Dock.Messages as Dock


type Msg
    = WindowManagerMsg WindowManager.Msg
    | DockMsg Dock.Msg
