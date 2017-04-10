module OS.WindowManager.Messages exposing (..)

import Draggable
import OS.WindowManager.Windows exposing (GameWindow)
import OS.WindowManager.Models exposing (WindowID, Position)
import OS.WindowManager.ContextHandler.Messages exposing (ContextMsg)
import Apps.Explorer.Models


type Msg
    = OpenWindow GameWindow
    | CloseWindow WindowID
    | OnDragBy Draggable.Delta
    | StartDragging WindowID
    | StopDragging
    | DragMsg (Draggable.Msg WindowID)
    | ContextHandlerMsg ContextMsg
