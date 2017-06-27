module Apps.Subscriptions exposing (subscriptions)

import Game.Data as Game
import Apps.Models exposing (..)
import Apps.Messages exposing (..)
import Apps.LogViewer.Subscriptions as LogViewer
import Apps.TaskManager.Subscriptions as TaskManager
import Apps.Browser.Subscriptions as Browser
import Apps.Explorer.Subscriptions as Explorer


subscriptions : Game.Data -> AppModel -> Sub Msg
subscriptions data model =
    case model of
        LogViewerModel model ->
            LogViewer.subscriptions data model
                |> Sub.map LogViewerMsg

        TaskManagerModel model ->
            TaskManager.subscriptions data model
                |> Sub.map TaskManagerMsg

        BrowserModel model ->
            Browser.subscriptions data model
                |> Sub.map BrowserMsg

        ExplorerModel model ->
            Explorer.subscriptions data model
                |> Sub.map ExplorerMsg
