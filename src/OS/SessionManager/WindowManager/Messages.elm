module OS.SessionManager.WindowManager.Messages exposing (Msg(..))

import Draggable
import OS.SessionManager.WindowManager.Models exposing (ID)
import Apps.Messages as Apps


type Msg
    = WindowMsg ID Apps.Msg
    | Close ID
    | Minimize ID
    | ToggleMaximize ID
    | SwitchContext ID
    | UpdateFocusTo (Maybe ID)
      -- WINDOW DRAGGIN'
    | OnDragBy Draggable.Delta
    | StartDragging ID
    | StopDragging
    | DragMsg (Draggable.Msg ID)
