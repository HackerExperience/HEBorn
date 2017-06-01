module OS.WindowManager.Messages exposing (..)

import Draggable
import OS.WindowManager.Models exposing (WindowID, Position)
import Apps.Models as Apps
import Apps.Messages as Apps


type
    Msg
    -- SPECIFIC APP
    = AppMsg Apps.AppMsg
    | OpenOrRestore Apps.App
    | Open Apps.App
    | MinimizeAll Apps.App
    | CloseAll Apps.App
    | WindowMsg WindowID Apps.AppMsg
      -- SPECIFIC WINDOW
    | Close WindowID
    | ToggleMaximize WindowID
    | Minimize WindowID
    | SwitchContext WindowID
    | UpdateFocusTo (Maybe WindowID)
    | Restore WindowID
      -- WINDOW DRAGGIN'
    | OnDragBy Draggable.Delta
    | StartDragging WindowID
    | StopDragging
    | DragMsg (Draggable.Msg WindowID)
