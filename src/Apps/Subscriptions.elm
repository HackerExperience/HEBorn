module Apps.Subscriptions exposing (subscriptions)

import Game.Models exposing (GameModel)
import Apps.Models exposing (..)
import Apps.Messages exposing (AppMsg(..))
import Apps.LogViewer.Subscriptions as LogViewer
import Apps.TaskManager.Subscriptions as TaskManager
import Apps.Browser.Subscriptions as Browser
import Apps.Explorer.Subscriptions as Explorer


subscriptions : GameModel -> AppModel -> Sub AppMsg
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
