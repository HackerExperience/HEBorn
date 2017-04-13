module OS.WindowManager.Messages exposing (..)

import Draggable
import OS.WindowManager.Windows exposing (GameWindow)
import OS.WindowManager.Models exposing (WindowID, Position)
import Apps.Explorer.Models


type Msg
    = OpenWindow GameWindow
    | CloseWindow WindowID
    | OnDragBy Draggable.Delta
    | StartDragging WindowID
    | StopDragging
    | DragMsg (Draggable.Msg WindowID)
    | ToggleMaximize WindowID
    | MinimizeWindow WindowID
