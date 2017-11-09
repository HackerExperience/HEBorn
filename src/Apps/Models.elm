module Apps.Models
    exposing
        ( AppModel(..)
        , Contexts(..)
        , contexts
        , name
        , title
        , icon
        , windowInitSize
        )

import Apps.Messages exposing (..)
import Apps.LogViewer.Models as LogViewer
import Apps.TaskManager.Models as TaskManager
import Apps.Browser.Models as Browser
import Apps.Explorer.Models as Explorer
import Apps.DBAdmin.Models as Database
import Apps.ConnManager.Models as ConnManager
import Apps.BounceManager.Models as BounceManager
import Apps.Finance.Models as Finance
import Apps.Hebamp.Models as Hebamp
import Apps.CtrlPanel.Models as CtrlPanel
import Apps.ServersGears.Models as ServersGears
import Apps.LocationPicker.Models as LocationPicker
import Apps.LanViewer.Models as LanViewer
import Apps.Email.Models as Email
import Apps.Bug.Models as Bug
import Apps.Calculator.Models as Calculator
import Apps.Apps exposing (..)
import Apps.Messages exposing (..)
import Game.Data as Game


type AppModel
    = LogViewerModel LogViewer.Model
    | TaskManagerModel TaskManager.Model
    | BrowserModel Browser.Model
    | ExplorerModel Explorer.Model
    | DatabaseModel Database.Model
    | ConnManagerModel ConnManager.Model
    | BounceManagerModel BounceManager.Model
    | FinanceModel Finance.Model
    | MusicModel Hebamp.Model
    | CtrlPanelModel CtrlPanel.Model
    | ServersGearsModel ServersGears.Model
    | LocationPickerModel LocationPicker.Model
    | LanViewerModel LanViewer.Model
    | EmailModel Email.Model
    | BugModel Bug.Model
    | CalculatorModel Calculator.Model


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
            ContextualApp

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

        MusicApp ->
            ContextlessApp

        CtrlPanelApp ->
            ContextlessApp

        ServersGearsApp ->
            ContextlessApp

        LocationPickerApp ->
            ContextlessApp

        LanViewerApp ->
            ContextualApp

        EmailApp ->
            ContextlessApp

        BugApp ->
            ContextualApp

        CalculatorApp ->
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

        MusicApp ->
            Hebamp.name

        CtrlPanelApp ->
            CtrlPanel.name

        ServersGearsApp ->
            ServersGears.name

        LocationPickerApp ->
            LocationPicker.name

        LanViewerApp ->
            LanViewer.name

        EmailApp ->
            Email.name

        BugApp ->
            Bug.name

        CalculatorApp ->
            Calculator.name


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

        MusicApp ->
            Hebamp.icon

        CtrlPanelApp ->
            CtrlPanel.icon

        ServersGearsApp ->
            ServersGears.icon

        LocationPickerApp ->
            LocationPicker.icon

        LanViewerApp ->
            LanViewer.icon

        EmailApp ->
            Email.icon

        BugApp ->
            Bug.icon

        CalculatorApp ->
            Calculator.icon


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

        MusicModel model ->
            Hebamp.title model

        CtrlPanelModel model ->
            CtrlPanel.title model

        ServersGearsModel model ->
            ServersGears.title model

        LocationPickerModel model ->
            LocationPicker.title model

        LanViewerModel model ->
            LanViewer.title model

        EmailModel model ->
            Email.title model

        BugModel model ->
            Bug.title model

        CalculatorModel model ->
            Calculator.title model


windowInitSize : App -> ( Float, Float )
windowInitSize app =
    case app of
        BrowserApp ->
            Browser.windowInitSize

        _ ->
            ( 600, 400 )
