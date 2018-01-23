module Apps.Subscriptions exposing (subscriptions)

import Apps.Config exposing (..)
import Apps.Models exposing (..)
import Apps.Messages exposing (..)
import Apps.LogViewer.Subscriptions as LogViewer
import Apps.TaskManager.Subscriptions as TaskManager
import Apps.Browser.Subscriptions as Browser
import Apps.Explorer.Subscriptions as Explorer
import Apps.DBAdmin.Subscriptions as Database
import Apps.LocationPicker.Subscriptions as LocationPicker


subscriptions : Config msg -> AppModel -> Sub msg
subscriptions config model =
    case model of
        LogViewerModel model ->
            LogViewer.subscriptions (logViewerConfig config) model
                |> Sub.map (LogViewerMsg >> config.toMsg)

        TaskManagerModel model ->
            TaskManager.subscriptions (taskManConfig config) model
                |> Sub.map (TaskManagerMsg >> config.toMsg)

        BrowserModel model ->
            Browser.subscriptions (browserConfig config) model
                |> Sub.map (BrowserMsg >> config.toMsg)

        ExplorerModel model ->
            Explorer.subscriptions (explorerConfig config) model
                |> Sub.map (ExplorerMsg >> config.toMsg)

        DatabaseModel model ->
            Database.subscriptions (dbAdminConfig config) model
                |> Sub.map (DatabaseMsg >> config.toMsg)

        LocationPickerModel model ->
            LocationPicker.subscriptions (locationPickerConfig config) model
                |> Sub.map (LocationPickerMsg >> config.toMsg)

        _ ->
            Sub.none
