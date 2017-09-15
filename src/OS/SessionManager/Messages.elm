module OS.SessionManager.Messages exposing (Msg(..))

import Game.Meta.Types exposing (Context(..))
import OS.SessionManager.WindowManager.Messages as WindowManager
import OS.SessionManager.Dock.Messages as Dock
import Apps.Messages as Apps


type alias WindowRef =
    -- SM.WindowRef creates a ciclid reference
    ( String, String )


type Msg
    = WindowManagerMsg WindowManager.Msg
    | AppMsg WindowRef Context Apps.Msg
    | DockMsg Dock.Msg
