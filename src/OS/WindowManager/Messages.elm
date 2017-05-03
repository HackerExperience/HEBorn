module OS.WindowManager.Messages exposing (..)

import Draggable
import OS.WindowManager.Windows exposing (GameWindow)
import OS.WindowManager.Models exposing (WindowID, Position)


type
    Msg
    -- SPECIFIC APP
    = OpenOrRestore GameWindow
    | Open GameWindow
    | MinimizeAll GameWindow
    | CloseAll GameWindow
      -- SPECIFIC WINDOW
    | Close WindowID
    | ToggleMaximize WindowID
    | Minimize WindowID
    | SwitchContext WindowID
    | UpdateFocusTo (Maybe WindowID)
      -- WINDOW DRAGGIN'
    | OnDragBy Draggable.Delta
    | StartDragging WindowID
    | StopDragging
    | DragMsg (Draggable.Msg WindowID)
