module Apps.Messages exposing (Msg(..))

import Apps.LogViewer.Messages as LogViewer
import Apps.TaskManager.Messages as TaskManager
import Apps.Browser.Messages as Browser
import Apps.Explorer.Messages as Explorer
import Apps.DBAdmin.Messages as Database
import Apps.ConnManager.Messages as ConnManager


type Msg
    = LogViewerMsg LogViewer.Msg
    | TaskManagerMsg TaskManager.Msg
    | BrowserMsg Browser.Msg
    | ExplorerMsg Explorer.Msg
    | DatabaseMsg Database.Msg
    | ConnManagerMsg ConnManager.Msg
