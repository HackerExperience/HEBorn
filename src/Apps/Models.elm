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


type App
    = LogViewerApp
    | TaskManagerApp


type AppModel
    = LogViewerModel LogViewer.Model
    | TaskManagerModel TaskManager.Model


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


name : App -> String
name app =
    case app of
        LogViewerApp ->
            LogViewer.name

        TaskManagerApp ->
            TaskManager.name


icon : App -> String
icon app =
    case app of
        LogViewerApp ->
            LogViewer.icon

        TaskManagerApp ->
            TaskManager.icon


title : AppModel -> String
title model =
    case model of
        LogViewerModel model ->
            LogViewer.title model

        TaskManagerModel model ->
            TaskManager.title model


model : App -> AppModel
model app =
    case app of
        LogViewerApp ->
            LogViewerModel LogViewer.initialModel

        TaskManagerApp ->
            TaskManagerModel TaskManager.initialModel
