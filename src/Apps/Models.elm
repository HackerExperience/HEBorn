module Apps.Models
    exposing
        ( AppModel(..)
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
import Apps.DBAdmin.Models as Database
import Apps.ConnManager.Models as ConnManager
import Apps.BounceManager.Models as BounceManager
import Apps.Finance.Models as Finance
import Apps.Apps exposing (..)


type AppModel
    = LogViewerModel LogViewer.Model
    | TaskManagerModel TaskManager.Model
    | BrowserModel Browser.Model
    | ExplorerModel Explorer.Model
    | DatabaseModel Database.Model
    | ConnManagerModel ConnManager.Model
    | BounceManagerModel BounceManager.Model
    | FinanceModel Finance.Model


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

        DatabaseApp ->
            ContextlessApp

        ConnManagerApp ->
            ContextlessApp

        BounceManagerApp ->
            ContextlessApp

        FinanceApp ->
            ContextlessApp


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

        DatabaseApp ->
            Database.name

        ConnManagerApp ->
            ConnManager.name

        BounceManagerApp ->
            BounceManager.name

        FinanceApp ->
            Finance.name


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

        DatabaseApp ->
            Database.icon

        ConnManagerApp ->
            ConnManager.icon

        BounceManagerApp ->
            BounceManager.icon

        FinanceApp ->
            Finance.icon


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

        DatabaseModel model ->
            Database.title model

        ConnManagerModel model ->
            ConnManager.title model

        BounceManagerModel model ->
            BounceManager.title model

        FinanceModel model ->
            Finance.title model


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

        DatabaseApp ->
            DatabaseModel Database.initialModel

        ConnManagerApp ->
            ConnManagerModel ConnManager.initialModel

        BounceManagerApp ->
            BounceManagerModel BounceManager.initialModel

        FinanceApp ->
            FinanceModel Finance.initialModel
