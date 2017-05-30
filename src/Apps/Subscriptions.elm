module Apps.Subscriptions exposing (subscriptions)

import Apps.Models exposing (..)
import Apps.Messages exposing (AppMsg(..))
import Apps.LogViewer.Models as LogViewer
import Apps.LogViewer.Messages as LogViewer
import Apps.LogViewer.Subscriptions as LogViewer
import Apps.TaskManager.Models as TaskManager
import Apps.TaskManager.Messages as TaskManager
import Apps.TaskManager.Subscriptions as TaskManager
import Apps.Browser.Models as Browser
import Apps.Browser.Messages as Browser
import Apps.Browser.Subscriptions as Browser


subscriptions game model =
    case model of
        LogViewerModel model ->
            LogViewer.subscriptions game model
                |> Sub.map LogViewerMsg

        TaskManagerModel model ->
            TaskManager.subscriptions game model
                |> Sub.map TaskManagerMsg

        BrowserModel model ->
            Browser.subscriptions game model
                |> Sub.map BrowserMsg
