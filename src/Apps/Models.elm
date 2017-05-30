module Apps.Models
    exposing
        ( AppModel(..)
        , App(..)
        , Contexts(..)
        , contexts
        , name
        , title
        , icon
        , model
        )

import Apps.LogViewer.Models as LogViewer
import Apps.TaskManager.Models as TaskManager
import Apps.Browser.Models as Browser
import Apps.Explorer.Models as Explorer


type App
    = LogViewerApp
    | TaskManagerApp
    | BrowserApp
    | ExplorerApp


type AppModel
    = LogViewerModel LogViewer.Model
    | TaskManagerModel TaskManager.Model
    | BrowserModel Browser.Model
    | ExplorerModel Explorer.Model


type Contexts
    = ContextualApp
    | ContextlessApp


contexts : App -> Contexts
contexts app =
    case app of
        LogViewerApp ->
            ContextualApp

        TaskManagerApp ->
            ContextualApp

        BrowserApp ->
            ContextlessApp

        ExplorerApp ->
            ContextualApp


name : App -> String
name app =
    case app of
        LogViewerApp ->
            LogViewer.name

        TaskManagerApp ->
            TaskManager.name

        BrowserApp ->
            Browser.name

        ExplorerApp ->
            Explorer.name


icon : App -> String
icon app =
    case app of
        LogViewerApp ->
            LogViewer.icon

        TaskManagerApp ->
            TaskManager.icon

        BrowserApp ->
            Browser.icon

        ExplorerApp ->
            Explorer.icon


title : AppModel -> String
title model =
    case model of
        LogViewerModel model ->
            LogViewer.title model

        TaskManagerModel model ->
            TaskManager.title model

        BrowserModel model ->
            Browser.title model

        ExplorerModel model ->
            Explorer.title model


model : App -> AppModel
model app =
    case app of
        LogViewerApp ->
            LogViewerModel LogViewer.initialModel

        TaskManagerApp ->
            TaskManagerModel TaskManager.initialModel

        BrowserApp ->
            BrowserModel Browser.initialModel

        ExplorerApp ->
            ExplorerModel Explorer.initialModel
