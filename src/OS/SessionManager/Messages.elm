module OS.SessionManager.Messages exposing (Msg(..))

import Game.Meta.Types exposing (Context(..))
import Game.Servers.Shared as Servers
import OS.SessionManager.Dock.Messages as Dock
import OS.SessionManager.WindowManager.Messages as WM
import OS.SessionManager.WindowManager.Models as WM
import OS.SessionManager.Types exposing (..)
import Apps.Messages as Apps


type Msg
    = EveryAppMsg (List Apps.Msg)
    | TargetedAppMsg Servers.ID WM.TargetContext (List Apps.Msg)
    | AppMsg WindowRef Context Apps.Msg
    | WindowManagerMsg ID WM.Msg
    | DockMsg Dock.Msg
