module OS.SessionManager.WindowManager.Messages exposing (Msg(..))

import Draggable
import Apps.Messages as Apps
import Game.Meta.Types exposing (Context(..))
import OS.SessionManager.WindowManager.Models exposing (..)


type Msg
    = AppMsg TargetContext ID Apps.Msg
    | EveryAppMsg Apps.Msg
      -- WINDOW Actions
    | Close ID
    | Minimize ID
    | ToggleMaximize ID
    | SetContext ID Context
    | UpdateFocusTo (Maybe ID)
      -- WINDOW DRAGGIN'
    | OnDragBy Draggable.Delta
    | StartDragging ID
    | StopDragging
    | DragMsg (Draggable.Msg ID)
