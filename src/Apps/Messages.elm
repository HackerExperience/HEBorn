module Apps.Messages exposing (AppMsg(..))

import Apps.LogViewer.Messages as LogViewer
import Apps.TaskManager.Messages as TaskManager
import Apps.Browser.Messages as Browser
import Apps.Explorer.Messages as Explorer


type AppMsg
    = LogViewerMsg LogViewer.Msg
    | TaskManagerMsg TaskManager.Msg
    | BrowserMsg Browser.Msg
    | ExplorerMsg Explorer.Msg
