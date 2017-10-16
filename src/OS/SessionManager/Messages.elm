module OS.SessionManager.Messages exposing (Msg(..))

import Game.Meta.Types exposing (Context(..))
import Game.Servers.Shared as Servers
import OS.SessionManager.Dock.Messages as Dock
import OS.SessionManager.WindowManager.Messages as WM
import OS.SessionManager.WindowManager.Models as WM
import OS.SessionManager.Types exposing (..)
import Apps.Messages as Apps
import Apps.Apps as Apps


type Msg
    = OpenApp (Maybe Context) Apps.App
    | WindowManagerMsg ID WM.Msg
    | DockMsg Dock.Msg
    | AppMsg WindowRef Context Apps.Msg
    | EveryAppMsg (List Apps.Msg)
    | TargetedAppMsg Servers.ID WM.TargetContext (List Apps.Msg)
