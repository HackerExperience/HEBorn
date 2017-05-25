module Apps.Messages exposing (AppMsg(..))

import Apps.LogViewer.Messages as LogViewer
import Apps.TaskManager.Messages as TaskManager


type AppMsg
    = LogViewerMsg LogViewer.Msg
    | TaskManagerMsg TaskManager.Msg
