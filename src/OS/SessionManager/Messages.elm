module OS.SessionManager.Messages exposing (Msg(..))

import OS.SessionManager.WindowManager.Messages as WindowManager
import OS.SessionManager.Dock.Messages as Dock
import Apps.Messages as Apps


type alias ServerID =
    String


type Msg
    = WindowManagerMsg WindowManager.Msg
    | AppMsg (Maybe ServerID) Apps.Msg
    | DockMsg Dock.Msg
