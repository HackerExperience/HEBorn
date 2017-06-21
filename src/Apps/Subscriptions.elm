module Apps.Subscriptions exposing (subscriptions)

import Game.Models as Game
import Apps.Models exposing (..)
import Apps.Messages exposing (..)
import Apps.LogViewer.Subscriptions as LogViewer
import Apps.TaskManager.Subscriptions as TaskManager
import Apps.Browser.Subscriptions as Browser
import Apps.Explorer.Subscriptions as Explorer


subscriptions : Game.Model -> AppModel -> Sub Msg
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
