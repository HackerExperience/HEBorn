module OS.SessionManager.WindowManager.Messages exposing (Msg(..))

import Draggable
import OS.SessionManager.WindowManager.Models exposing (WindowID)
import Apps.Messages as Apps


type Msg
    = WindowMsg WindowID Apps.Msg
    | Close WindowID
    | Minimize WindowID
    | ToggleMaximize WindowID
    | SwitchContext WindowID
    | UpdateFocusTo (Maybe WindowID)
      -- WINDOW DRAGGIN'
    | OnDragBy Draggable.Delta
    | StartDragging WindowID
    | StopDragging
    | DragMsg (Draggable.Msg WindowID)
