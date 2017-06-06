module Apps.Subscriptions exposing (subscriptions)

import Apps.Models exposing (..)
import Apps.Messages exposing (AppMsg(..))
import Apps.LogViewer.Messages as LogViewer
import Apps.LogViewer.Subscriptions as LogViewer
import Apps.TaskManager.Messages as TaskManager
import Apps.TaskManager.Subscriptions as TaskManager
import Apps.Browser.Messages as Browser
import Apps.Browser.Subscriptions as Browser
import Apps.Explorer.Messages as Explorer
import Apps.Explorer.Subscriptions as Explorer


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

        ExplorerModel model ->
            Explorer.subscriptions game model
                |> Sub.map ExplorerMsg
