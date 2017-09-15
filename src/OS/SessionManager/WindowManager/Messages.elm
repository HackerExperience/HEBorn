module OS.SessionManager.WindowManager.Messages exposing (Msg(..))

import Draggable
import Apps.Messages as Apps
import Game.Meta.Types exposing (Context(..))


type alias WindowID =
    -- WM.ID creates a ciclic reference
    String


type Msg
    = WindowMsg WindowID Apps.Msg
    | AppMsg WindowID Context Apps.Msg
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
